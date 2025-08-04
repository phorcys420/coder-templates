FROM codercom/enterprise-base:latest

ARG ANDROID_SDK_VERSION=11076708
ENV ANDROID_SDK_URL="https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_VERSION}_latest.zip"

USER root

# Java
RUN apt update --yes && \
    apt install --yes --no-install-recommends \
        openjdk-21-jdk \
        openjdk-21-jre \
        libpulse0 && \
    rm -rf /var/lib/apt/lists/*

# TODO: Gradle

# Install the Android commandline tools
ENV ANDROID_HOME="/usr/local/android"
ENV CMDLINE_TOOLS_HOME="${ANDROID_HOME}/cmdline-tools"

RUN mkdir -p "$CMDLINE_TOOLS_HOME" && \
    wget "$ANDROID_SDK_URL" -O "/tmp/android-sdk.zip" && \
    unzip "/tmp/android-sdk.zip" -d "$CMDLINE_TOOLS_HOME" && \
    mv "$CMDLINE_TOOLS_HOME/cmdline-tools" "$CMDLINE_TOOLS_HOME/latest" && \
    rm -rf "/tmp/android-sdk.zip"

# Add the command line tools to the path
ENV PATH="${PATH}:${CMDLINE_TOOLS_HOME}/latest/bin"

# Accept sdkmanager licenses
RUN yes | sdkmanager --licenses

# Install required tools, TODO: see why CircleCI installs multiple versions of build-tools
RUN sdkmanager \
    "tools" \
    "platform-tools" \
    "build-tools;34.0.0"

# Install Android and Google's Maven repositories and Google Play services
RUN sdkmanager \
    "extras;android;m2repository" \
    "extras;google;m2repository" \
    "extras;google;google_play_services"

# Install Android platforms and system images
# TODO: see how we handle all the platforms and system images for all the different versions, also diff between google_apis and google_apis_playstore
RUN sdkmanager \
    "platforms;android-34" \
    "system-images;android-34;google_apis_playstore;x86_64"

# Make the Android SDK folder accessible by all users
RUN chmod 755 "$ANDROID_HOME" -R

# Add all the other Android SDK tools to the path
ENV PATH="${PATH}:${ANDROID_HOME}/emulator:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools"

# Add the "coder" user to the "kvm" group to allow it to use the /dev/kvm device
RUN groupadd -r kvm -g 108 && \
    usermod -aG kvm coder

COPY --chmod=775 install-droidvnc.sh /usr/local/bin/install-droidvnc.sh

USER coder