# Install Android platforms and system images
# TODO: move this into an android-vm feature
# TODO: explain diff between google_apis and google_apis_playstore
# TODO: see how we can make this a dynamic parameter/preset thing
ANDROID_IMAGE=${ANDROID_IMAGE:-'system-images;android-34;google_apis_playstore;x86_64'}

sudo --preserve-env=PATH env sdkmanager "$ANDROID_IMAGE"