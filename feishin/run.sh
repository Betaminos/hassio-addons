#!/bin/sh
set -eu

# The Supervisor writes the add-on's configured options to /data/options.json.
# These prefill (and with server_lock, lock) the web client's server login
# dialog — same variables as the upstream docker-compose.yaml. jq prints
# JSON booleans as bare true/false, which is exactly what the settings.js
# template expects; empty optional strings become the upstream "" defaults.
SERVER_NAME="$(jq -r '.server_name // empty' /data/options.json)"
SERVER_TYPE="$(jq -r '.server_type // empty' /data/options.json)"
SERVER_URL="$(jq -r '.server_url // empty' /data/options.json)"
SERVER_LOCK="$(jq -r '.server_lock // empty' /data/options.json)"
LEGACY_AUTHENTICATION="$(jq -r '.legacy_authentication // empty' /data/options.json)"
ANALYTICS_DISABLED="$(jq -r '.analytics_disabled // empty' /data/options.json)"
export SERVER_NAME SERVER_TYPE SERVER_URL SERVER_LOCK LEGACY_AUTHENTICATION ANALYTICS_DISABLED

# REMOTE_URL (Navidrome custom sharing URLs) stays at the upstream default
# (empty): this store does not target that setup.

# Run Feishin exactly the command the upstream image runs. Its
# docker-entrypoint.sh renders settings.js and the nginx config from
# /etc/nginx/templates/*.template, substituting the exported SERVER_*
# variables, then starts nginx. exec keeps this process's PID for nginx, so
# Supervisor stop signals (SIGTERM) reach nginx directly and shut it down
# cleanly.
exec /docker-entrypoint.sh nginx -g "daemon off;"
