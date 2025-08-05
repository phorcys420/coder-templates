#!/usr/bin/env bash

set -euo pipefail

# Injected by terraform through templatefile()
ANDROID_VM_NAME='${ANDROID_VM_NAME}'
ANDROID_DEVICE='${ANDROID_DEVICE}'
ANDROID_IMAGE='${ANDROID_IMAGE}'

# TODO: maybe don't do --force
# TODO: don't use shorthand arguments
echo "[+] Creating Android VM ($ANDROID_IMAGE on $ANDROID_DEVICE)"
avdmanager -v create avd --force -n "$ANDROID_VM_NAME" -d "$ANDROID_DEVICE" -k "$ANDROID_IMAGE"

# TODO: remove this stupid workaround lol
sudo chown root:kvm /dev/kvm

echo "[+] Starting Android VM"
emulator -avd "$ANDROID_VM_NAME" -no-window #>/tmp/android-emulator.log 2>&1 &

#adb wait-for-device
#echo "[+] Android VM is ready !"