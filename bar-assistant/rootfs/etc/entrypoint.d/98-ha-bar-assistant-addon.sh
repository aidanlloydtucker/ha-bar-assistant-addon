#!/usr/bin/env sh
set -eu

APP_BASE_DIR="${APP_BASE_DIR:-/var/www/cocktails}"
OPTIONS_FILE="/data/options.json"

log() {
    echo "[HA-BAR-ASSISTANT] $*"
}

config() {
    key="$1"
    fallback="$2"

    if [ -f "${OPTIONS_FILE}" ]; then
        jq -r --arg key "${key}" --arg fallback "${fallback}" '.[$key] // $fallback' "${OPTIONS_FILE}"
    else
        printf '%s\n' "${fallback}"
    fi
}

set_env_file_value() {
    key="$1"
    value="$2"
    env_file="${APP_BASE_DIR}/.env"

    tmp_file="$(mktemp)"
    touch "${env_file}"
    grep -vE "^${key}=" "${env_file}" > "${tmp_file}" || true
    printf '%s=%s\n' "${key}" "${value}" >> "${tmp_file}"
    mv "${tmp_file}" "${env_file}"
    chown www-data:www-data "${env_file}" || true
}

start_meilisearch() {
    log "Starting local Meilisearch"
    export MEILI_MASTER_KEY
    export MEILI_ENV=production
    export MEILI_NO_ANALYTICS=true

    /usr/bin/meilisearch \
        --db-path /data/meilisearch \
        --http-addr 127.0.0.1:7700 &

    MEILI_PID="$!"
}

wait_for_meilisearch() {
    attempt=1

    log "Waiting for local Meilisearch on 127.0.0.1:7700"
    while [ "${attempt}" -le 60 ]; do
        if ! kill -0 "${MEILI_PID}" >/dev/null 2>&1; then
            log "Meilisearch exited before it became ready"
            exit 1
        fi

        if bash -c '</dev/tcp/127.0.0.1/7700' >/dev/null 2>&1; then
            log "Local Meilisearch is accepting connections"
            return 0
        fi

        sleep 1
        attempt=$((attempt + 1))
    done

    log "Timed out waiting for local Meilisearch"
    exit 1
}

start_redis() {
    log "Starting local Redis"
    redis-server \
        --bind 127.0.0.1 \
        --protected-mode no \
        --dir /data/redis \
        --appendonly yes \
        --daemonize yes
}

start_proxy() {
    log "Preparing Salt Rim config"
    export API_URL MEILISEARCH_URL
    envsubst < /opt/salt-rim/config.js > /opt/salt-rim/html/config.js

    CONFIG_HASH="$(md5sum /opt/salt-rim/html/config.js | cut -d' ' -f1)"
    sed -i "s|<script src=\"/config.js\"></script>|<script src=\"/config.js?v=${CONFIG_HASH}\"></script>|g" /opt/salt-rim/html/index.html

    log "Starting add-on web proxy on port 8099"
    nginx -c /etc/nginx/ha-bar-assistant-addon.conf -g "daemon off;" &
}

mkdir -p /data/bar-assistant /data/meilisearch /data/redis
chown -R www-data:www-data /data/bar-assistant /data/meilisearch /data/redis || true

if [ -d "${APP_BASE_DIR}/storage/bar-assistant" ] && [ ! -L "${APP_BASE_DIR}/storage/bar-assistant" ]; then
    rm -rf "${APP_BASE_DIR}/storage/bar-assistant"
fi

ln -sfn /data/bar-assistant "${APP_BASE_DIR}/storage/bar-assistant"
chown -h www-data:www-data "${APP_BASE_DIR}/storage/bar-assistant" || true

if [ ! -s /data/meili_master_key ]; then
    openssl rand -hex 32 > /data/meili_master_key
    chmod 600 /data/meili_master_key
fi

API_URL="$(config 'api_url' '/bar')"
MEILISEARCH_URL="$(config 'meilisearch_url' '/search')"
ALLOW_REGISTRATION="$(config 'allow_registration' 'true')"
USE_REDIS="$(config 'use_redis' 'true')"
MEILI_MASTER_KEY="$(config 'meili_master_key' '')"

if [ -z "${MEILI_MASTER_KEY}" ] || [ "${MEILI_MASTER_KEY}" = "null" ]; then
    MEILI_MASTER_KEY="$(cat /data/meili_master_key)"
fi

set_env_file_value APP_URL "${API_URL}"
set_env_file_value MEILISEARCH_KEY "${MEILI_MASTER_KEY}"
set_env_file_value MEILISEARCH_HOST "http://127.0.0.1:7700"
set_env_file_value ALLOW_REGISTRATION "${ALLOW_REGISTRATION}"

if [ "${USE_REDIS}" = "true" ]; then
    set_env_file_value REDIS_HOST "127.0.0.1"
    set_env_file_value CACHE_DRIVER "redis"
    set_env_file_value SESSION_DRIVER "redis"
    start_redis
else
    set_env_file_value CACHE_DRIVER "file"
    set_env_file_value SESSION_DRIVER "file"
fi

start_meilisearch
wait_for_meilisearch
start_proxy
