FROM ubuntu:22.04

# Prerequisites
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        curl git unzip xz-utils zip libglu1-mesa openjdk-17-jdk wget protobuf-compiler usbutils

# Set up new user
RUN useradd -ms /bin/bash developer
USER developer
WORKDIR /home/developer

# Prepare Android directories and system variables
RUN mkdir -p Android/sdk/cmdline-tools/
ENV ANDROID_SDK_ROOT /home/developer/Android/sdk
RUN mkdir -p .android && touch .android/repositories.cfg

# Set up Android SDK
RUN wget -O cmdline-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip?hl=pt-br
RUN unzip cmdline-tools.zip && rm cmdline-tools.zip
RUN mv cmdline-tools Android/sdk/cmdline-tools/latest
RUN cd Android/sdk/cmdline-tools/latest/bin && yes | ./sdkmanager --licenses
ENV PATH "$PATH:/home/developer/Android/sdk/platform-tools"

# Set up Flutter SDK
RUN wget -O flutter.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.0-stable.tar.xz
RUN tar xf flutter.tar.xz && rm flutter.tar.xz
ENV PATH "$PATH:/home/developer/flutter/bin"
RUN flutter precache

# Installing necessary Android Platforms
RUN cd ~/Android/sdk/cmdline-tools/latest/bin && \
    ./sdkmanager "platform-tools" \
        "build-tools;30.0.3" "platforms;android-30" "sources;android-30" \
        "build-tools;33.0.2" "platforms;android-33" "sources;android-33"

# Setting up app directory
WORKDIR /home/developer/app/

# Installing app dependencies
COPY --chown=developer ./pubspec.lock ./pubspec.yaml ./
RUN flutter pub get; exit 0
RUN dart pub global activate protoc_plugin
ENV PATH "$PATH":"/home/developer/.pub-cache/bin"

# Dart code generation
COPY --chown=developer ./lib ./lib
COPY --chown=developer ./android ./android
RUN dart run build_runner build --delete-conflicting-outputs

# Compiling protobuf files
COPY --chown=developer ./proto ./proto
RUN protoc proto/*.proto -I. --dart_out=./lib

RUN flutter build apk --release
RUN cp ./build/app/outputs/apk/release/app-release.apk ./release.apk