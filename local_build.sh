#!/bin/bash

# This script is equivalent to the github action but tuned to run locally
# if you cloned the raspOVOS repo you can use this script as long as qemu is properly setup in your machine
# NOTE: also check local_build_all.sh

set -e

echo_green() {
    echo -e "\x1B[1m>>> \x1B[0m\x1B[32;1m$@\x1B[0m"
}

error() {
    echo -e "\x1B[31;1mERROR: $@\x1B[0m"
    exit 1
}

BUILD_DIR="/tmp/rpi-image-modifier-raspOVOS"
RASPOVOS_DIR="$(pwd -P)"  # raspOVOS repo

# === REQUIRED ARGUMENTS ===
script_path="build_audio_base.sh" # relative path

base_image="https://downloads.raspberrypi.com/raspios_lite_arm64/images/raspios_lite_arm64-2025-05-13/2025-05-13-raspios-bookworm-arm64-lite.img.xz"
image_maxsize="8G"
image_output_path="raspovos-dev-bookworm-arm64-lite.img.xz"

# === OPTIONAL FLAGS ===
shrink_image=false
compress_with_xz=false
extra_xz_args=""
shell="/bin/bash"


# === Parse arguments ===
while [[ $# -gt 0 ]]; do
    case "$1" in
        --script-path) script_path="$2"; shift ;;
        --base-image) base_image="$2"; shift ;;
        --image-maxsize) image_maxsize="$2"; shift ;;
        --image-output-path) image_output_path="$2"; shift ;;
        --shrink) shrink_image=true ;;
        --compress-with-xz) compress_with_xz=true ;;
        --extra-xz-args) extra_xz_args="$2"; shift ;;
        --shell) shell="$2"; shift ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
    shift
done

# === Validation ===
if [[ -z "$script_path" ]]; then
    error "You must specify --script-path"
fi

if [[ ! -f "$script_path" ]]; then
    error "Script not found: $script_path"
fi

if $shrink_image; then
    sudo wget -q -O /usr/local/bin/pishrink.sh https://raw.githubusercontent.com/Drewsif/PiShrink/master/pishrink.sh
    sudo chmod +x /usr/local/bin/pishrink.sh
fi

mkdir -vp "${BUILD_DIR}/mnt"
cd "${BUILD_DIR}"

# === Download or copy base image ===
if [[ "$base_image" =~ ^https?:// ]]; then
    echo_green "Downloading image from URL: ${base_image}"
    wget -q -O rpi.img "${base_image}"
elif [[ -f "$base_image" ]]; then
    echo_green "Copying local image: ${base_image}"
    #cp -v "$base_image" rpi.img
    #ln -s "$base_image" rpi.img
else
    error "Invalid base_image path or URL: ${base_image}"
fi

# === Decompression ===
case "$(file -b --mime-type rpi.img)" in
    application/x-xz) echo_green "Decompressing xz" && mv -v rpi.img rpi.img.xz && xz -T0 -d rpi.img.xz ;;
    application/gzip) echo_green "Decompressing gzip" && mv -v rpi.img rpi.img.gz && gzip -d rpi.img.gz ;;
    application/x-bzip2) echo_green "Decompressing bzip2" && mv -v rpi.img rpi.img.bz2 && bzip2 -d rpi.img.bz2 ;;
    application/x-lzma) echo_green "Decompressing lzma" && mv -v rpi.img rpi.img.lzma && lzma -d rpi.img.lzma ;;
esac

echo_green "Expanding image to ${image_maxsize}"
fallocate -l "${image_maxsize}" rpi.img
LOOPBACK_DEV="$(sudo losetup -fP --show rpi.img)"
echo_green "Created loopback device ${LOOPBACK_DEV}"

echo_green "Expanding partition"
sudo parted rpi.img resizepart 2 '100%FREE'
sudo losetup -d "${LOOPBACK_DEV}"
LOOPBACK_DEV="$(sudo losetup -fP --show rpi.img)"

echo_green "Resizing filesystem"
sudo e2fsck -fy "${LOOPBACK_DEV}p2"  # Run filesystem check to fix errors
sudo resize2fs "${LOOPBACK_DEV}p2"   # Resize after ensuring consistency

echo_green "Mounting image"
sudo mount -v "${LOOPBACK_DEV}p2" "${BUILD_DIR}/mnt"

if grep -qF /boot/firmware "${BUILD_DIR}/mnt/etc/fstab"; then
    BOOT_MOUNTPOINT="/boot/firmware"
else
    BOOT_MOUNTPOINT="/boot"
fi
sudo mount -v "${LOOPBACK_DEV}p1" "${BUILD_DIR}/mnt${BOOT_MOUNTPOINT}"

SCRIPT_NAME="/_rpi_custom.sh"
echo_green "Copying script into image"
sudo cp -v "${RASPOVOS_DIR}/${script_path}" "mnt${SCRIPT_NAME}"
sudo chmod +x "mnt${SCRIPT_NAME}"

sudo cp /usr/bin/qemu-aarch64-static "${BUILD_DIR}/mnt/usr/bin"
echo_green "Running script inside systemd-nspawn container"
sudo systemd-nspawn \
    --directory="${BUILD_DIR}/mnt" \
    --hostname=raspberrypi \
    --bind="${RASPOVOS_DIR}:/mounted-github-repo" \
    "${shell}" "${SCRIPT_NAME}"

echo_green "Cleaning up"
sudo rm -v "mnt${SCRIPT_NAME}"

echo_green "Unmounting loopback device"
sudo umount -vR mnt
sudo losetup -d "${LOOPBACK_DEV}"

if $shrink_image; then
    echo_green "Shrinking image"
    sudo pishrink.sh -s rpi.img
else
    echo_green "Skipping shrink"
fi

IMAGE_SIZE="$(du -b rpi.img | awk '{ print $1 }')"
echo_green "Image size: ${IMAGE_SIZE} bytes"

echo_green "Moving image to ${image_output_path}"
mv -v rpi.img "${RASPOVOS_DIR}/${image_output_path}"

if $compress_with_xz; then
    echo_green "Compressing image with xz"
    xz -T0 ${extra_xz_args} "${RASPOVOS_DIR}/${image_output_path}"
    image_output_path="${image_output_path}.xz"
fi

IMAGE_SHA256SUM="$(sha256sum "${RASPOVOS_DIR}/${image_output_path}" | awk '{ print $1 }')"
echo_green "Final output:"
echo "  Path: ${image_output_path}"
echo "  Size: ${IMAGE_SIZE}"
echo "  SHA256: ${IMAGE_SHA256SUM}"
