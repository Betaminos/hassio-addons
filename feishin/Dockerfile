#syntax=docker/dockerfile:1
###############################################################################
# HAOS add-on wrapping the official multi-arch Feishin web image.
#
# Upstream: https://github.com/jeffvli/feishin (GPL-3.0)
# Base image: ghcr.io/jeffvli/feishin — nginx-unprivileged (alpine-slim)
# serving the built Feishin web client, listening on 9180. The web client is
# stateless: server credentials and player settings live in the browser's
# local storage, so the add-on needs no persistent /data beyond the
# Supervisor's options.json.
#
# Nothing is compiled here. This layer only adds jq (for reading the add-on
# options), the license text, and an entrypoint that maps the Supervisor
# options onto the upstream SERVER_* environment variables before the nginx
# entrypoint renders its templates.
#
# To move to a new Feishin release: bump FEISHIN_VERSION, update config.json's
# "version" upstream part, push — CI bumps the packaging suffix and publishes.
###############################################################################

ARG FEISHIN_VERSION=1.17.0
ARG RELEASE_NOTES_URL=https://github.com/jeffvli/feishin/releases/tag/v
FROM ghcr.io/jeffvli/feishin:${FEISHIN_VERSION}

# Feishin's is the only base image in this store that is not root-by-default,
# which forces the two lines below before anything can run. Both exist to
# keep the build and runtime behavior identical to the other add-ons:
#
# 1) ARGs declared before FROM are not in scope inside the build stage. The
#    bare ARG inherits the default from the global declaration above, so the
#    license URL in the RUN resolves to .../v1.17.0/LICENSE (without it the
#    variable expands empty and the build 404s on .../v/LICENSE).
ARG FEISHIN_VERSION

# 2) The base image ships USER 101 (nginxinc's unprivileged variant), so
#    without this line the RUN below executes as uid 101 and apk fails
#    immediately on permissions. Build-time apk needs root, and run.sh
#    needs root at runtime to read the Supervisor's root-only (chmod 600)
#    /data/options.json — the same root-run setup as the other add-ons in
#    this store (Maloja documents the same reasoning). nginx then follows
#    the standard root-master / unprivileged-worker split of the official
#    nginx image.
USER root

# jq is used by run.sh to read the Supervisor-provided add-on options.
# GPL-3.0 compliance: ship the license text alongside the app
# (same pattern as AudioMuse-AI and Rewind).
RUN apk add --no-cache jq curl \
    && mkdir -p /usr/share/doc/feishin \
    && curl -fsSL -o /usr/share/doc/feishin/LICENSE \
       "https://raw.githubusercontent.com/jeffvli/feishin/v${FEISHIN_VERSION}/LICENSE" \
    && apk del curl

COPY run.sh /run.sh
RUN chmod +x /run.sh

# EXPOSE is documentation only — the Supervisor routes traffic via the
# `ports` mapping in config.json. Feishin always listens on 9180 inside
# the container, so this stays fixed either way.
EXPOSE 9180

# CRITICAL: override the base image's ENTRYPOINT so run.sh runs first — it
# reads the options and exports the SERVER_* variables BEFORE the nginx
# entrypoint renders /etc/nginx/templates/*.template (settings.js and the
# server config). run.sh then execs the upstream entrypoint with the
# upstream CMD, unchanged.
ENTRYPOINT ["/run.sh"]
