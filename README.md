# Home Assistant Bar Assistant Add-on

This repository contains a Home Assistant add-on wrapper for the upstream Bar Assistant Docker setup.

The add-on lives in [`bar-assistant`](bar-assistant/) and adapts the documented Compose services into the add-on model:

- Salt Rim web client
- Bar Assistant API
- Meilisearch
- Redis

Because Home Assistant add-ons are single managed containers, the add-on uses `docker_api: true` to supervise the official Bar Assistant sidecar containers and exposes them through one HA-facing web port, `8099`.

See [`bar-assistant/README.md`](bar-assistant/README.md) for configuration details.
