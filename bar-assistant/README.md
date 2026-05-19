# Home Assistant Add-on: Bar Assistant

This add-on adapts the upstream Bar Assistant Docker Compose stack to the Home Assistant add-on model.

The upstream stack runs separate containers for:

- Salt Rim web client
- Bar Assistant API
- Meilisearch
- Redis

Home Assistant add-ons are single managed containers, so this add-on uses the official Bar Assistant API image as its base, copies in the Salt Rim static client, and runs local Meilisearch and Redis processes inside the add-on. Persistent data is stored under the add-on `/data` volume, and the add-on exposes a single web endpoint on port `8099`.

## Configuration

Default URLs are path-based:

- `api_url`: `/bar`
- `meilisearch_url`: `/search`

The add-on reverse proxy maps those paths to the API and Meilisearch services and serves Salt Rim at `/`.

If the Salt Rim client cannot reach the API with relative URLs in your browser, set these to full URLs that point at the add-on port, for example:

- `api_url`: `http://homeassistant.local:8099/bar`
- `meilisearch_url`: `http://homeassistant.local:8099/search`

If `meili_master_key` is left empty, the add-on generates and persists one in `/data/meili_master_key`.

## Notes

The Bar Assistant project recommends versioned images and does not publish a `latest` tag for the application images. The add-on currently tracks the documented major versions:

- `barassistant/server:v5`
- `barassistant/salt-rim:v4`
- `getmeili/meilisearch:v1.15`
