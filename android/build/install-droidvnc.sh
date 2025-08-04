#!/usr/bin/env bash
set -euo pipefail

packageName='net.christianbeier.droidvnc_ng'

suggestedVersion=$(curl --silent --show-error https://f-droid.org/api/v1/packages/$packageName | jq '.suggestedVersionCode')

apkName="${packageName}_${suggestedVersion}.apk"
apkPath="/tmp/$apkName"

echo "[+] Downloading droidVNC-NG apk"
curl "https://f-droid.org/repo/$apkName" -o "$apkPath"

echo "[+] Waiting for device..."
adb wait-for-device

echo "[+] Waiting for device to be ready..."
until [ "$(adb shell getprop sys.boot_completed)" == "1" ]; do
    #: # do nothing: just wait
    echo "[DEBUG] boot is not completed"
done

adb shell input keyevent 0
sleep 15 # TODO: remove
echo "[+] Device is ready"

echo "[+] Installing droidVNC-NG apk"
adb install "$apkPath"

EXTERNAL_STORAGE="/storage/emulated/0"

echo "[+] Writing default droidVNC-NG config"
adb shell mkdir -p "$EXTERNAL_STORAGE/Android/data/$packageName/files"

# TODO : better way to write this file
# TODO : explain why no cursor (TLDR: laggy)
cat << EOF > /tmp/droidvnc_default.json
{
    "port": 5900,
    "showPointers": false,
    "fileTransfer": true,
    "password": "supersecure",
    "accessKey": "evenmoresecure",
    "startOnBoot": false,
    "startOnBootDelay": 0
}
EOF
adb push /tmp/droidvnc_default.json "$EXTERNAL_STORAGE/Android/data/$packageName/files/defaults.json"

echo "[+] Setting droidVNC-NG as the enabled accessibility service"
adb shell settings put secure enabled_accessibility_services $packageName/$packageName.InputService:$packageName/$packageName.MainService

echo "[+] Granting android.permission.POST_NOTIFICATIONS permission to droidVNC-NG"
adb shell pm grant $packageName android.permission.POST_NOTIFICATIONS

echo "[+] Allow droidVNC-NG to project media (capture the screen)"
adb shell appops set $packageName PROJECT_MEDIA allow

echo "[+] Starting droidVNC-NG..."
adb shell am start-foreground-service \
 -n $packageName/.MainService \
 -a $packageName.ACTION_START \
 --es $packageName.EXTRA_REQUEST_ID 1338 \
 --es $packageName.EXTRA_PASSWORD supersecure \
 --es $packageName.EXTRA_ACCESS_KEY evenmoresecure \
 --ei $packageName.EXTRA_PORT 5900 \
 --ez $packageName.EXTRA_VIEW_ONLY false

echo "[+] Forwarding the necessary ports to the host workspace"
adb forward tcp:5900 tcp:5900 # VNC Server
adb forward tcp:5800 tcp:5800 # built-in noVNC viewer