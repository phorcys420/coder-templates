#!/usr/bin/env bash

# Injected by terraform through templatefile()
NOVNC_LISTEN_HOST='${NOVNC_LISTEN_HOST}'
NOVNC_HOST_TO_PROXY='${NOVNC_HOST_TO_PROXY}'

echo "[noVNC] Installing noVNC"
sudo apt update -y
sudo apt install -y websockify && git clone https://github.com/novnc/noVNC && mv noVNC/vnc.html noVNC/index.html

echo "[noVNC] Starting noVNC"
websockify "$NOVNC_LISTEN_HOST" "$NOVNC_HOST_TO_PROXY" --web "$HOME/noVNC" >/tmp/novnc.log 2>&1 &