# Home Assistant Add-on: Bar Assistant

This add-on adapts the upstream Bar Assistant Docker Compose stack to the Home Assistant add-on model.

The upstream stack runs separate containers for:

- Salt Rim web client
- Bar Assistant API
- Meilisearch
- Redis

Home Assistant add-ons are single managed containers, so this add-on uses the official Bar Assistant API image as its base, copies in the Salt Rim static client, and runs local Meilisearch and Redis processes inside the add-on. Persistent data is stored under the add-on `/data` volume (Laravel storage, including the SQLite database and uploads, in `/data/storage`), and the add-on exposes a single web endpoint on port `8099`.

## Configuration

Default URLs are path-based:

- `api_url`: `/bar`
- `meilisearch_url`: `/search`

The add-on reverse proxy maps those paths to the API and Meilisearch services and serves Salt Rim at `/`.

If the Salt Rim client cannot reach the API with relative URLs in your browser, set these to full URLs that point at the add-on port, for example:

- `api_url`: `http://homeassistant.local:8099/bar`
- `meilisearch_url`: `http://homeassistant.local:8099/search`

`auto_login` signs every browser that opens the web UI in as the first registered user, with no password. Anyone who can reach port `8099` gets that account, so only enable it on a trusted network. It works by issuing a normal 14-day login token through Salt Rim's SSO callback; logging out and reloading signs you back in.

If `meili_master_key` is left empty, the add-on generates and persists one in `/data/meili_master_key`.

## Notes

The Bar Assistant project recommends versioned images and does not publish a `latest` tag for the application images. The add-on pins exact releases, so a rebuild never pulls new code. Auto-login depends on Salt Rim's SSO callback and stored login state, so retest it when bumping these:

- `barassistant/server:6.9.1`
- `barassistant/salt-rim:5.8.0`
- `getmeili/meilisearch:v1.50.0`

Meilisearch runs with `--experimental-dumpless-upgrade`, so its index is upgraded in place when the bundled version changes.

There is no Home Assistant ingress panel. Salt Rim only works at the root of a domain, and ingress serves add-ons under `/api/hassio_ingress/<token>/`, so open the web UI on port `8099` instead.
