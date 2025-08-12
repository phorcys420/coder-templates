#!/usr/bin/env bash

# Injected by terraform through templatefile()
WEB_SERVER_LISTEN_HOST='${WEB_SERVER_LISTEN_HOST}'
ADB_SERVER_HOST='${ADB_SERVER_HOST}'

STATIC_SITE_PATH="/tmp/adb-tools-static-site"

#echo "[adb-tools] Installing websockify"
#sudo apt-get update -y
#sudo apt-get install -y websockify 

echo "[adb-tools] Downloading frontend"
wget https://nightly.link/phorcys420/adb-tools/workflows/deploy/main/adb-tools-static-site.zip
unzip adb-tools-static-site.zip -d "$STATIC_SITE_PATH"

# TODO: remove this once we support coder_script ordering
sleep 20

echo "[adb-tools] Starting websockify"
websockify "$WEB_SERVER_LISTEN_HOST" "$ADB_SERVER_HOST" --web "$STATIC_SITE_PATH" >/tmp/adb-tools-websockify.log 2>&1 &