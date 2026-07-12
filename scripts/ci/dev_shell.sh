#!/bin/bash
# Interactive shell inside a raspOVOS image for debugging (systemd-nspawn +
# qemu-user binfmt). Changes made inside persist in the image file.
#
# Usage (root): scripts/ci/dev_shell.sh <image[.xz]>

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=scripts/ci/image_mount.sh
source "${SCRIPT_DIR}/image_mount.sh"

IMG="${1:?usage: dev_shell.sh <image>}"

command -v systemd-nspawn >/dev/null 2>&1 || fail "systemd-container is required"
[[ -f /usr/bin/qemu-aarch64-static ]] || fail "qemu-user-static is required"

trap cleanup_image EXIT
mount_image "$IMG" rw
# nspawn manages its own /proc etc.; no bind_system_mounts needed here

cp /usr/bin/qemu-aarch64-static "$MNT/usr/bin/"
log "Entering image (exit the shell to unmount)"
systemd-nspawn --directory="$MNT" --hostname=raspOVOS /bin/bash || true
rm -f "$MNT/usr/bin/qemu-aarch64-static"
