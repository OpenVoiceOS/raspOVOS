#!/bin/bash

# This script is equivalent to the github action but tuned to run locally
# if you cloned the raspOVOS repo you can use this script as long as qemu is properly setup in your machine
# NOTE: runs local_build.sh for all language specific images

set -e

echo_green() {
    echo -e "\x1B[1m>>> \x1B[0m\x1B[32;1m$*\x1B[0m"
}

echo_yellow() {
    echo -e "\x1B[1m>>> \x1B[0m\x1B[33;1m$*\x1B[0m"
}

error() {
    echo -e "\x1B[31;1mERROR: $*\x1B[0m"
    exit 1
}

BASEDIR="$(pwd -P)"

LANGS=(ca gl en es eu pt nl de it multilingual)
AUDIO_BASE="rpi-bookworm-arm64-audio-base.img.xz"
RASPOVOS_BASE="raspOVOS-bookworm-arm64-DEV.img.xz"

echo_green "Starting build: Audio base image"
if /bin/bash ./build.sh --script-path build_audio_base.sh --image-output-path "$AUDIO_BASE"; then
    echo_green "Audio base image built successfully"
else
    error "Failed to build audio base image"
fi

echo_green "Starting build: raspOVOS base image"
if /bin/bash ./build.sh --script-path build_raspOVOS.sh --image-output-path "$RASPOVOS_BASE" --base-image "$BASEDIR/$AUDIO_BASE"; then
    echo_green "raspOVOS base image built successfully"
else
    error "Failed to build raspOVOS base image"
fi



LANGS=(ca gl en es eu pt nl de it multilingual)
RASPOVOS_BASE="https://github.com/OpenVoiceOS/raspOVOS/releases/download/raspOVOS-DEV-bookworm-arm64-lite-2025-05-29/raspOVOS-DEV-bookworm-arm64-lite.img.xz"

for lang in "${LANGS[@]}"; do
    IMG_VAR="RASPOVOS_${lang}"
    IMG_PATH="${!IMG_VAR}"
    SCRIPT="build_raspOVOS_${lang}.sh"

    echo_green "Processing language: $lang"
    if [[ -f "$SCRIPT" ]]; then
        echo_yellow "Running build script: $SCRIPT"
        if /bin/bash ./build.sh --script-path "$SCRIPT" --image-output-path "$IMG_PATH" --base-image "$RASPOVOS_BASE"; then
            echo_green "Build for $lang completed successfully"
        else
            error "Build failed for $lang"
        fi
    else
        echo_yellow "Script $SCRIPT not found, skipping build for $lang"
    fi
done
