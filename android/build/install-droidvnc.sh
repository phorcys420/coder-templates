#!/bin/bash
set -euo pipefail

packageName='net.christianbeier.droidvnc_ng'

suggestedVersion=$(curl --silent --show-error https://f-droid.org/api/v1/packages/$packageName | jq '.suggestedVersionCode')

apkName="${packageName}_${suggestedVersion}.apk"
apkPath="/tmp/$apkName"

echo "[+] Downloading droidVNC-NG apk"
curl "https://f-droid.org/repo/$apkName" -o "$apkPath"

echo "[+] Waiting for device..."
adb wait-for-device

# TODO fix tmis
echo "[+] Waiting for device to be ready..."
while [ $(adb shell getprop sys.boot_completed) != "1" ]; do
    echo "[DEBUG] not ready"
done

adb shell input keyevent 0

echo "[+] Installing droidVNC-NG apk"
adb install "$apkPath"

EXTERNAL_STORAGE="/storage/emulated/0"

echo "[+] Writing default droidVNC-NG config"
adb shell mkdir -p "$EXTERNAL_STORAGE/Android/data/$packageName/files"

# TODO : better

# TODO : explain why no cursor
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

echo "[+] forward tcp:5900 tcp:5900"
adb forward tcp:5900 tcp:5900