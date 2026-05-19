ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base-debian:bookworm
FROM ${BUILD_FROM}

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
        docker.io \
        jq \
        nginx \
        openssl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /etc/nginx/sites-enabled/default

COPY rootfs /
