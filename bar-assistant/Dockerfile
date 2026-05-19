FROM barassistant/salt-rim:v4 AS salt-rim
FROM getmeili/meilisearch:v1.15 AS meilisearch

FROM barassistant/server:v5

ARG BUILD_ARCH
ARG BUILD_VERSION

LABEL \
    io.hass.name="Bar Assistant" \
    io.hass.description="Bar Assistant and Salt Rim packaged for Home Assistant" \
    io.hass.type="app" \
    io.hass.version=${BUILD_VERSION} \
    io.hass.arch=${BUILD_ARCH}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        gettext-base \
        jq \
        openssl \
        redis-server \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY --from=meilisearch /bin/meilisearch /usr/local/bin/meilisearch
COPY --from=salt-rim --chown=www-data:www-data /var/www/html /opt/salt-rim/html
COPY --from=salt-rim --chown=www-data:www-data /var/www/config.js /opt/salt-rim/config.js

COPY rootfs /

RUN chmod +x /etc/entrypoint.d/98-ha-bar-assistant-addon.sh
