#!/bin/bash
# Tier 3 — full boot smoke test in qemu-system-aarch64 (no hardware).
#
# Boots the image on the 'raspi3b' machine using the kernel/initrd shipped in
# the image's boot partition, watches the serial console, logs in, and
# asserts the OVOS stack came up:
#   - every enabled ovos-* user unit reaches 'active' (retry budget)
#   - journalctl -p err -b is empty modulo scripts/ci/journal-allowlist.txt
#
# LIMITATION (by design): raspi3b emulation does not exercise Pi 4/5
# firmware, device-tree, HAT or audio paths — those live in the human
# release checklist (docs/dev/release-checklist.md).
#
# Usage: scripts/ci/qemu_boot_test.sh <image[.xz]> [artifact-dir]
# Needs: qemu-system-aarch64, expect, and root only for kernel extraction.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=scripts/ci/image_mount.sh
source "${SCRIPT_DIR}/image_mount.sh"

IMG="${1:?usage: qemu_boot_test.sh <image> [artifact-dir]}"
ARTIFACTS="${2:-./boot-test-artifacts}"
BOOT_TIMEOUT="${RASPOVOS_BOOT_TIMEOUT:-1500}"    # seconds to reach login (raspi3b TCG is slow)
UNIT_BUDGET="${RASPOVOS_UNIT_BUDGET:-120}"       # seconds for units to settle
USER_NAME="ovos"
USER_PASS="ovos"

command -v qemu-system-aarch64 >/dev/null 2>&1 || fail "qemu-system-aarch64 is required"
command -v expect >/dev/null 2>&1 || fail "expect is required"

mkdir -p "$ARTIFACTS"
SERIAL_LOG="$ARTIFACTS/serial.log"
: > "$SERIAL_LOG"

WORK="$(mktemp -d /tmp/raspovos-boot.XXXXXX)"
cleanup_boot() {
    set +e
    [[ -n "${QEMU_PID:-}" ]] && kill "$QEMU_PID" 2>/dev/null
    cleanup_image
    rm -rf "$WORK"
    set -e
}
trap cleanup_boot EXIT

# --- extract kernel + initrd from the image's boot partition ---
log "Extracting kernel/initrd from image"
mount_image "$IMG" ro
BOOT_DIR="$MNT/boot/firmware"
[[ -d "$BOOT_DIR" ]] || BOOT_DIR="$MNT/boot"
cp "$BOOT_DIR/kernel8.img" "$WORK/kernel8.img" || fail "kernel8.img not found in boot partition"
cp "$BOOT_DIR/bcm2710-rpi-3-b.dtb" "$WORK/pi3.dtb" || fail "bcm2710-rpi-3-b.dtb not found in boot partition"
# the boot partition carries one initramfs per kernel flavor
# (initramfs7/initramfs8/initramfs_2712...); we boot kernel8.img so pick
# initramfs8, falling back to the first match on older layouts
INITRD=""
for cand in "$BOOT_DIR/initramfs8" "$BOOT_DIR"/initramfs*; do
    if [[ -f "$cand" ]]; then
        cp "$cand" "$WORK/initrd"
        INITRD="$WORK/initrd"
        break
    fi
done
# keep a decompressed raw image copy for qemu (mount_image may have made one)
if [[ "$(file -b --mime-type "$IMG")" == "application/x-xz" ]]; then
    RAW_IMG="$(dirname "$MNT")/image.img"
    cp "$RAW_IMG" "$WORK/disk.img"
else
    cp "$IMG" "$WORK/disk.img"
fi
cleanup_image
trap 'set +e; [[ -n "${QEMU_PID:-}" ]] && kill "$QEMU_PID" 2>/dev/null; rm -rf "$WORK"; set -e' EXIT

# --- boot ---
log "Booting image in qemu (timeout ${BOOT_TIMEOUT}s), serial -> $SERIAL_LOG"
# the Raspberry Pi kernel has no virtio drivers and its only PCI controller
# driver is pcie-brcmstb, so neither 'virt' virtio-mmio nor 'virt' PCI
# devices ever appear. Use the real Pi 3 machine model instead: SD card via
# the native mmc controller, network as a USB device on the dwc2 controller.
# raspi3b fixes RAM at 1 GiB — the lite image explicitly targets Pi 3.

# the raspi3b SD controller requires a power-of-two disk size
disk_bytes="$(stat -c %s "$WORK/disk.img")"
pow2=1
while (( pow2 < disk_bytes )); do pow2=$((pow2 * 2)); done
truncate -s "$pow2" "$WORK/disk.img"

QEMU_ARGS=(
    -M raspi3b
    -kernel "$WORK/kernel8.img"
    -dtb "$WORK/pi3.dtb"
    -append "console=ttyAMA0,115200 root=/dev/mmcblk0p2 rootwait rw"
    -drive "file=$WORK/disk.img,format=raw,if=sd"
    -netdev user,id=net0 -device usb-net,netdev=net0
    -nographic -serial mon:stdio
)
[[ -n "$INITRD" ]] && QEMU_ARGS+=(-initrd "$INITRD")

export SERIAL_LOG USER_NAME USER_PASS BOOT_TIMEOUT UNIT_BUDGET ARTIFACTS
RC=0
expect "${SCRIPT_DIR}/qemu_boot_test.expect" qemu-system-aarch64 "${QEMU_ARGS[@]}" || RC=$?
[[ $RC -eq 0 ]] || fail "Tier 3 boot smoke failed (rc=$RC) — see $SERIAL_LOG"

# --- journal errors modulo allowlist (dumped between markers by expect) ---
log "Checking journal errors against allowlist"
JOURNAL_ERR="$ARTIFACTS/journal-err.log"
sed -n '/JOURNAL-ERR-BEGIN/,/JOURNAL-ERR-END/p' "$SERIAL_LOG" \
    | grep -vE 'JOURNAL-ERR-(BEGIN|END)|^-- ' > "$JOURNAL_ERR" || true
# strip comments/blank lines from the allowlist first — grep -f treats every
# line as a live regex and an empty line would match (and suppress) everything
ALLOW_PATTERNS="$(grep -vE '^\s*(#|$)' "${SCRIPT_DIR}/journal-allowlist.txt")"
UNEXPECTED="$(grep -vEf <(echo "$ALLOW_PATTERNS") "$JOURNAL_ERR" | grep -vE '^\s*$' || true)"
if [[ -n "$UNEXPECTED" ]]; then
    echo "$UNEXPECTED" >&2
    fail "unexpected journal errors (add benign ones to journal-allowlist.txt WITH a why-comment)"
fi

log "Tier 3 OK"
