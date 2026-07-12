#!/bin/bash

# This script is equivalent to the github actions but tuned to run locally.
# It drives local_build.sh: first the base image (build_raspOVOS_base_lite.sh,
# optionally build_raspOVOS_base_full.sh on top), then the per-language images
# from lang_builds/{lite,hybrid,offline}/.
# Requires qemu-user-static + systemd-nspawn, see local_build.sh --help.

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

usage() {
    cat <<EOF
Usage: $0 [--variant lite|hybrid|offline] [--langs "xx yy"] [--base-image URL|FILE] [--skip-base]

Builds the raspOVOS base image, then the per-language images for one variant.

Options:
  --variant VARIANT    Which lang_builds variant to build (default: lite)
  --langs "xx yy"      Space-separated language codes (default: every script
                       present in lang_builds/<variant>/)
  --base-image PATH    Base image for the base build (default: local_build.sh's
                       pinned Raspberry Pi OS Lite URL)
  --skip-base          Reuse an existing local base image instead of building it;
                       requires --base-image pointing at a raspOVOS base image
  -h, --help           Show this help and exit
EOF
}

BASEDIR="$(pwd -P)"
variant="lite"
langs=""
base_image=""
skip_base=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help) usage; exit 0 ;;
        --variant) variant="$2"; shift ;;
        --langs) langs="$2"; shift ;;
        --base-image) base_image="$2"; shift ;;
        --skip-base) skip_base=true ;;
        *) echo "Unknown option: $1"; usage; exit 1 ;;
    esac
    shift
done

[[ -d "lang_builds/$variant" ]] || error "Unknown variant: $variant (expected lite, hybrid or offline)"

if [[ -z "$langs" ]]; then
    langs="$(find "lang_builds/$variant" -name 'build_raspOVOS_*.sh' -printf '%f\n' \
        | sed 's/build_raspOVOS_\(.*\)\.sh/\1/' | sort | tr '\n' ' ')"
fi

# BASE_NAME is the output filename local_build.sh writes into the repo root;
# BASE_PATH is the absolute path the language builds consume.
BASE_NAME="raspOVOS-DEV-bookworm-arm64-${variant}-base.img"
BASE_PATH="$BASEDIR/$BASE_NAME"

if $skip_base; then
    [[ -f "$base_image" ]] || error "--skip-base requires --base-image pointing at an existing raspOVOS base image"
    BASE_PATH="$(realpath "$base_image")"
    echo_yellow "Skipping base build, reusing: $BASE_PATH"
else
    echo_green "Starting build: raspOVOS base image (lite)"
    base_args=()
    [[ -n "$base_image" ]] && base_args=(--base-image "$base_image")
    /bin/bash ./local_build.sh --script-path build_raspOVOS_base_lite.sh \
        --image-output-path "$BASE_NAME" "${base_args[@]}" \
        || error "Failed to build raspOVOS base image"
    if [[ "$variant" == "offline" ]]; then
        echo_green "Starting build: raspOVOS base image (full, needed for offline langs)"
        /bin/bash ./local_build.sh --script-path build_raspOVOS_base_full.sh \
            --image-output-path "$BASE_NAME" --base-image "$BASE_PATH" \
            || error "Failed to build raspOVOS full base image"
    fi
fi

for lang in $langs; do
    SCRIPT="lang_builds/$variant/build_raspOVOS_${lang}.sh"
    OUTPUT="raspOVOS-bookworm-arm64-${variant}-${lang}.img"

    echo_green "Processing language: $lang ($variant)"
    if [[ -f "$SCRIPT" ]]; then
        echo_yellow "Running build script: $SCRIPT"
        /bin/bash ./local_build.sh --script-path "$SCRIPT" \
            --image-output-path "$OUTPUT" --base-image "$BASE_PATH" \
            || error "Build failed for $lang"
        echo_green "Build for $lang completed successfully: $OUTPUT"
    else
        echo_yellow "Script $SCRIPT not found, skipping build for $lang"
    fi
done
