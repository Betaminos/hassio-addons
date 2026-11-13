# hassio-addons

[![Build add-on images](https://github.com/Betaminos/hassio-addons/actions/workflows/build.yml/badge.svg)](https://github.com/Betaminos/hassio-addons/actions/workflows/build.yml)

Home Assistant OS add-on store for self-hosted music tools around
[Navidrome](https://www.navidrome.org), targeting **ARM64 (Raspberry Pi 5)**.

| Add-on | What it does | Web UI | Upstream | License |
| ------ | ------------ | ------ | -------- | ------- |
| [AudioMuse-AI](#audiomuse-ai) | Sonic analysis, clustering, smart playlists | Port 8000 | [NeptuneHub/AudioMuse-AI](https://github.com/NeptuneHub/AudioMuse-AI) | AGPL-3.0 |
| [Feishin](#feishin) | Web music player for Navidrome, Jellyfin and Subsonic | Port 42020 | [jeffvli/feishin](https://github.com/jeffvli/feishin) | GPL-3.0 |
| [Maloja](#maloja) | Scrobble database, listening statistics and charts | Port 42010 | [krateng/maloja](https://github.com/krateng/maloja) | GPL-3.0 |
| [Rewind](#rewind) | Year-in-review listening stats with music playback | Port 42000 | [BernardoGiordano/rewind](https://github.com/BernardoGiordano/rewind) | GPL-3.0 |

All add-ons are **aarch64-only** and are unmodified repackages of pinned
upstream releases (see [Third-party licenses](#third-party-licenses)).

## Add-ons

### AudioMuse-AI
Sonic analysis, clustering and smart playlists for Navidrome (native aarch64
build with embedded PostgreSQL). Web UI on port 8000. Point it at your
Navidrome via the Setup Wizard, then pair it with the
[AudioMuse-AI Navidrome plugin](https://github.com/NeptuneHub/AudioMuse-AI-NV-plugin)
for Instant Mix in all Subsonic clients.

### Feishin
Browser-based music player for Navidrome, Jellyfin and Subsonic
([jeffvli/feishin](https://github.com/jeffvli/feishin)) — modern UI, a smart
playlist editor for Navidrome, synchronized lyrics, and scrobbling back to
the server. The web client plays through the HTML5 web player backend only
(no MPV backend, no gapless), and it is stateless: server credentials and
player settings live in each browser's local storage, so the server is
configured once per browser/device. Web UI on port 42020. With the
[AudioMuse-AI Navidrome plugin](https://github.com/NeptuneHub/AudioMuse-AI-NV-plugin)
active on your Navidrome, Feishin's similar-songs and artist-radio requests
are served by AudioMuse-AI's sonic analysis.

### Maloja
Self-hosted music scrobble database with listening statistics and charts —
a Spotify Wrapped-style year-in-review, fully local
([krateng/maloja](https://github.com/krateng/maloja)). Web UI on port 42010
(host port configurable in the add-on's Network settings). Before first
start, set the admin password on the add-on's Configuration tab — it refuses
to start without one.

### Rewind
Spotify Wrapped–style listening stats for Navidrome
([BernardoGiordano/rewind](https://github.com/BernardoGiordano/rewind)) —
stories-style yearly recap, top songs/artists/albums/genres, listening
clock, streaks, with music streamed from Navidrome during the slides. Reads
the live Navidrome database directly from the share (read-only). Web UI on
port 42000. Requires the Navidrome add-on on this instance with its data
folder in `/share/navidrome` (`data_folder: /share/navidrome`), so the live
`navidrome.db` is available.

## Install

**Requirements:** the add-on store needs Home Assistant **OS or Supervised**
(it does not work on Container installs), and every add-on in this store is
**aarch64-only** (e.g. Raspberry Pi 5).

1. Settings → Add-ons → Add-on Store → ⋮ → Manage add-on repositories → add
   `https://github.com/betaminos/hassio-addons`.
2. Install the add-on you want, configure, start.

## Support

- **Packaging, installation or wiring problems** (add-on won't start, ports,
  updates): open an issue in
  [this repository](https://github.com/Betaminos/hassio-addons/issues).
- **Bugs in the add-on's behavior**: report those upstream —
  [AudioMuse-AI](https://github.com/NeptuneHub/AudioMuse-AI/issues), 
  [Feishin](https://github.com/jeffvli/feishin/issues), 
  [Maloja](https://github.com/krateng/maloja/issues),
  [Rewind](https://github.com/BernardoGiordano/rewind/issues). The images
  here ship the upstream software unmodified, so behavioral fixes have to
  happen there.

## Wiring AudioMuse-AI to Navidrome

1. Start the AudioMuse-AI add-on and open `http://<pi-ip>:8000`.
2. Run the Setup Wizard: point it at your Navidrome instance (URL and
   credentials), then start the first analysis of your library.
3. Pair it with the AudioMuse-AI Navidrome plugin (download `audiomuseai.ndp`
   from the upstream releases and add it in Navidrome) to get Instant Mix
   and similar songs in all Subsonic clients.

## Wiring Feishin to Navidrome

1. On the Feishin add-on's Configuration tab, set `server_url` to your
   Navidrome address (e.g. `http://<pi-ip>:4533`). The web client runs in
   the browser, so this address must be reachable from the devices you
   browse from, not just from the Pi itself. `server_name` and
   `server_type` prefill the login dialog; `server_lock: true` locks the
   server settings so only username and password remain editable.
2. Start the add-on and open `http://<pi-ip>:42020`, then log in with your
   Navidrome credentials. Repeat the login on each browser/device —
   settings live in the browser, not on the Pi.
3. For AudioMuse-AI-powered similar songs and artist radio inside Feishin,
   enable the AudioMuse-AI plugin on your Navidrome (see
   [Wiring AudioMuse-AI to Navidrome](#wiring-audiomuse-ai-to-navidrome));
   Feishin needs no extra setup for it.

## Wiring Maloja to Navidrome

1. Start the Maloja add-on and open `http://<pi-ip>:42010`.
2. In Maloja's settings, create an API key (one per scrobbler is recommended).
3. In Navidrome, set `ListenBrainz.BaseURL` to
   `http://<pi-ip>:42010/apis/listenbrainz/1/`
   (env: `ND_LISTENBRAINZ_BASEURL`).
4. In Navidrome: user profile → Personal → enable *Scrobble to ListenBrainz*
   and paste the Maloja API key as the token.

Optional: add free Last.fm/Spotify API keys in Maloja's settings to get artist
images in the UI. To backfill history, drop a Last.fm/Spotify/ListenBrainz
export or another Maloja export into the import folder in the add-on data
directory (`/data`).

## Wiring Rewind to Navidrome

1. Make sure the Navidrome add-on runs with `data_folder: /share/navidrome`
   (the live database then lives at `/share/navidrome/navidrome.db`).
2. On the Rewind add-on's Configuration tab, set `navidrome_url` to your
   Navidrome address (e.g. `http://<pi-ip>:4533`) — needed for cover art,
   music in the slideshows, and manual scrobbles.
3. Start the add-on and open `http://<pi-ip>:42000`.
4. Log in with any Navidrome user (multi-user mode), or set both
   `navidrome_user` and `navidrome_api_key` in the Configuration tab to pin
   Rewind to a single user.

## Update automation

Upstream releases are tracked by a self-hosted
[Renovate](https://github.com/renovatebot/renovate) (AGPL-3.0) instance that
runs as a scheduled GitHub Actions workflow *inside this repository* — no
third-party app is installed, and it accesses the repo only through a
least-privilege, repository-scoped token. When AudioMuse-AI, Feishin or Maloja
publishes a release, Renovate opens a pull request bumping the version pins
in the affected add-on's `Dockerfile` and `config.json`; merging it triggers
CI to rebuild and publish the image. Renovate itself is build tooling only —
it is not part of any published add-on image or add-on data.

## Third-party licenses

- **AudioMuse-AI** © NeptuneHub —
  [AGPL-3.0](https://github.com/NeptuneHub/AudioMuse-AI/blob/main/LICENSE).
  Source: https://github.com/NeptuneHub/AudioMuse-AI (this image embeds an
  unmodified build of the upstream release pinned in the add-on's
  `Dockerfile`).
- **Feishin** © jeffvli —
  [GPL-3.0](https://github.com/jeffvli/feishin/blob/development/LICENSE).
  Source: https://github.com/jeffvli/feishin (this image embeds an unmodified
  copy of the official `ghcr.io/jeffvli/feishin` Docker image, at the tag
  pinned in the add-on's `Dockerfile`).
- **Maloja** © krateng —
  [GPL-3.0](https://github.com/krateng/maloja/blob/master/LICENSE).
  Source: https://github.com/krateng/maloja (this image embeds an unmodified
  copy of the official `krateng/maloja` Docker image, at the upstream tag
  pinned in the add-on's `Dockerfile`).
- **Rewind** © Bernardo Giordano —
  [GPL-3.0](https://github.com/BernardoGiordano/rewind/blob/master/LICENSE).
  Source: https://github.com/BernardoGiordano/rewind (this image embeds an
  unmodified copy of the official `bernardogiordano/rewind` Docker image,
  at the digest pinned in the add-on's `Dockerfile`).

## Packaging files disclosure

The packaging files in this repository (Dockerfiles, `run.sh`, workflows,
Renovate configuration, JSON configs) were written by an LLM at my direction;
I reviewed, adjusted, and tested them. I make no copyright claim over them —
treat them as public domain, reuse freely, no attribution required.
