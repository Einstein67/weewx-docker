# weewx Docker image (unofficial)

Minimal Docker image to run weewx in a Python virtualenv. The image ships a small entrypoint that prepares locales, activates the venv, creates a default configuration on first run and then execs the requested command.

See the upstream project: https://weewx.com/

**What this image does**

-   installs weewx into `/root/weewx-venv`
-   provides an entrypoint at `/usr/local/bin/docker-entrypoint.sh` that:
    -   generates the runtime locale requested by `LANG`/`LC_ALL` if missing,
    -   activates the virtualenv, and
    -   creates a default `weewx.conf` (using `weectl`) and appends `logging.conf` on first run.

**Important files**

-   `docker-entrypoint.sh` - container entrypoint script
-   `Dockerfile` - image build instructions
-   `logging.conf` - log configuration appended to created `weewx.conf`

**Environment variables**

-   `LANG` (default: `en_US.UTF-8`) — locale used by the container; can be set at runtime and the entrypoint will attempt to generate it if not present.
-   `LC_ALL` (optional) — overrides `LANG` if set.
-   `TZ` (default: `Etc/UTC`) — timezone used by the container.
-   `WEEWX_VERSION` (build-time) — version of weewx installed when building the image.

Note: `WEEWX_VERSION` and similar are build-time variables. To change the installed weewx version you must rebuild the image.

**Volumes / persistent data**

-   `/root/weewx-data` — weewx data directory (database, config). Mount a host directory here to keep your data persistent.
-   `/root/weewx-html` — generated HTML output. Mount a host directory to serve pages with an external web server (example: nginx). If you provide custom configuration file, keep in mind that this path must be set as HTML_ROOT in it.

Example `docker-compose` service (this repo includes `docker-compose.yaml`):

```yaml
services:
	weewx:
		build: .
        container_name: weewx
		restart: unless-stopped
		environment:
			- LANG=sk_SK.UTF-8
			- LC_ALL=sk_SK.UTF-8
			- TZ=Europe/Bratislava
		volumes:
			- ./data:/root/weewx-data:rw
			- ./html:/root/weewx-html:rw
```

Quick `docker` examples:

Run locally using provided docker-compose.yaml:

```bash
docker compose up --build
```

## Important, please read before run

**Locale behaviour**
The entrypoint will try to generate the locale specified by `LC_ALL`/`LANG` at container start (using `localedef` or `locale-gen` when available). This makes it possible for users to pull the [published image](https://hub.docker.com/r/tfilo/weewx/tags) and select their preferred locale at runtime without rebuilding the image.

**First-run configuration**
On first start (when `/data/weewx.conf` is missing) the entrypoint runs `weectl station create` to generate a minimal configuration and then appends `logging.conf` into the generated `weewx.conf`.

It is strongly recommended to run it for fist time with empty data directory because while running `weectl station create` there is multiple folders created in data directory and can simplify later moddifications for you. After first run, as soon as you see log message `INFO weewx.engine: Starting main packet loop.` you can stop it using `docker compose down`, than customise `/data/weewx.conf` to your preference. You can add required extensions in `/data/bin/user` or add new skins into  `/data/skins`. Than start up it again using `docker compose up`. Keep in mind that content of [logging.conf](./logging.conf) must be preserved in end of `/data/weewx.conf` file.