#!/bin/bash
# Shared helpers for the CI tiers: loop-mount a raspOVOS image (xz or raw)
# and clean up reliably. Sourced by assert_image.sh / chroot_checks.sh /
# dev_shell.sh — not executed directly. Callers must run as root.
#
# Usage:
#   source "$(dirname "$0")/image_mount.sh"
#   mount_image "<img path>" [rw]     # sets $MNT (rootfs, boot at $MNT/boot*)
#   trap cleanup_image EXIT

set -euo pipefail

MNT=""
_LOOP=""
_WORK=""

log() { echo -e "\x1B[1m>>> \x1B[0m\x1B[32;1m$*\x1B[0m"; }
fail() { echo -e "\x1B[31;1mFAIL: $*\x1B[0m" >&2; exit 1; }

mount_image() {
    local img="$1"
    local mode="${2:-ro}"
    [[ -f "$img" ]] || fail "image not found: $img"
    [[ "$(id -u)" == "0" ]] || fail "must run as root (loop mounts)"

    _WORK="$(mktemp -d /tmp/raspovos-ci.XXXXXX)"
    MNT="${_WORK}/mnt"
    mkdir -p "$MNT"

    case "$(file -b --mime-type "$img")" in
        application/x-xz)
            log "Decompressing $img (xz)"
            xz -T0 -dk -c "$img" > "${_WORK}/image.img"
            img="${_WORK}/image.img"
            ;;
        *) ;;
    esac

    _LOOP="$(losetup -fP --show "$img")"
    log "Loop device: ${_LOOP}"

    local opts=""
    [[ "$mode" == "ro" ]] && opts="-o ro"
    # shellcheck disable=SC2086
    mount $opts "${_LOOP}p2" "$MNT"
    if [[ -d "$MNT/boot/firmware" ]]; then
        # shellcheck disable=SC2086
        mount $opts "${_LOOP}p1" "$MNT/boot/firmware"
    else
        # shellcheck disable=SC2086
        mount $opts "${_LOOP}p1" "$MNT/boot"
    fi
    log "Mounted rootfs at $MNT"
}

# Bind-mount the host's /proc, /sys, /dev into the image rootfs so chrooted
# processes work (python multiprocessing, /dev/null, …). cleanup_image's
# `umount -R` tears these down with the rest.
bind_system_mounts() {
    mount --bind /proc "$MNT/proc"
    mount --bind /sys "$MNT/sys"
    mount --bind /dev "$MNT/dev"
    mount --bind /dev/pts "$MNT/dev/pts"
}

cleanup_image() {
    set +e
    if [[ -n "$MNT" && -d "$MNT" ]]; then
        umount -R "$MNT" 2>/dev/null
    fi
    [[ -n "$_LOOP" ]] && losetup -d "$_LOOP" 2>/dev/null
    [[ -n "$_WORK" ]] && rm -rf "$_WORK"
    set -e
}
