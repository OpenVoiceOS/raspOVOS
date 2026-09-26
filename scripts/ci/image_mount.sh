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
#
# /tmp is a tmpfs from the host, not a bind and not the image's own /tmp.
# python's tempfile.gettempdir() raises "No usable temporary directory found"
# the moment a write to /tmp fails, and ovos_config takes a NamedLock at
# import, so that error arrives as an import error and hides whatever the
# check meant to measure. Three languages failed that way on dev on
# 2026-09-26 and seven did not; which property of the image separates them is
# not established. A host tmpfs is correct whichever it is, because it depends
# on neither the image's free space nor the mode of its /tmp. It costs the
# image no bytes and changes none of them.
bind_system_mounts() {
    mount --bind /proc "$MNT/proc"
    mount --bind /sys "$MNT/sys"
    mount --bind /dev "$MNT/dev"
    mount --bind /dev/pts "$MNT/dev/pts"
    # A missing /tmp is reported by the caller's own check, so this only
    # declines to mount and never hides the fact.
    if [[ -d "$MNT/tmp" ]]; then
        mount -t tmpfs -o size=256m,mode=1777 tmpfs "$MNT/tmp"
    fi
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
