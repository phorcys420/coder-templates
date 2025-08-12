#!/usr/bin/env bash

# Injected by terraform through templatefile()
NOVNC_LISTEN_HOST='${NOVNC_LISTEN_HOST}'
NOVNC_HOST_TO_PROXY='${NOVNC_HOST_TO_PROXY}'

# TODO: support a noVNC repo already being present
# TODO: move to git-clone module once coder_script ordering is supported
echo "[noVNC] Installing noVNC"
sudo apt-get update -y
sudo apt-get install -y websockify && git clone https://github.com/novnc/noVNC && mv noVNC/vnc.html noVNC/index.html

echo "[noVNC] Starting noVNC"
websockify "$NOVNC_LISTEN_HOST" "$NOVNC_HOST_TO_PROXY" --web "$HOME/noVNC" >/tmp/novnc.log 2>&1 &