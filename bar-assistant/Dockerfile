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

USER root

RUN mkdir -p /var/lib/apt/lists/partial \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        gettext-base \
        jq \
        openssl \
        redis-server \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY --from=meilisearch /bin/meilisearch /usr/bin/meilisearch
COPY --from=meilisearch /lib/ld-musl-*.so.1 /lib/
COPY --from=meilisearch /usr/lib/libgcc_s.so.1 /usr/lib/
COPY --from=salt-rim --chown=www-data:www-data /var/www/html /opt/salt-rim/html
COPY --from=salt-rim --chown=www-data:www-data /var/www/config.js /opt/salt-rim/config.js

COPY rootfs /

RUN rm -rf /var/www/cocktails/storage/bar-assistant \
    && ln -s /data/bar-assistant /var/www/cocktails/storage/bar-assistant \
    && chmod +x /etc/entrypoint.d/98-ha-bar-assistant-addon.sh /usr/bin/meilisearch

USER root
