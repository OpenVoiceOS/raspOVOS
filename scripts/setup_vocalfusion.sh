#!/bin/bash
# Exit on error
# If something goes wrong just stop.
# it allows the user to see issues at once rather than having
# scroll back and figure out what went wrong.
set -e

REPO_URL="https://github.com/OpenVoiceOS/VocalFusionDriver.git"
SRC_PATH="/tmp/vocalfusion"
KERNEL_VERSION=$(ls /boot/vmlinuz-* | sort -V | tail -n 1 | sed 's|/boot/vmlinuz-||')
BOOT_DIRECTORY="/boot"

git clone "$REPO_URL" "$SRC_PATH"

cd "$SRC_PATH/driver"
make clean
make KDIR="/lib/modules/$KERNEL_VERSION/build"

cp vocalfusion-soundcard.ko "/lib/modules/$KERNEL_VERSION/vocalfusion-soundcard.ko"
depmod -a

cp *.dtbo "$BOOT_DIRECTORY/firmware/overlays/"

# Copy vocalfusion overlay to the system
echo "Copying vocalfusion overlay"
cp -rv /mounted-github-repo/overlays/vocalfusion/* /