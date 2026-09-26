#!/bin/bash
# Tier 2 — chroot functional checks (no pid1, no audio, no network).
# Executes arm64 binaries inside the image via qemu-user binfmt and verifies
# the shipped software actually loads:
#   1. the shipped /tmp is a usable temp directory
#   2. the OVOS venv imports (per-variant list in scripts/ci/imports.d/)
#   3. pip's dependency resolution is consistent (pip check)
#   4. every shipped systemd unit passes systemd-analyze verify
#
# Anything that needs a running systemd, audio hardware or the network
# belongs in Tier 3 (qemu boot) or the hardware release checklist.
#
# Usage (root): scripts/ci/chroot_checks.sh <image[.xz]> [variant]

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=scripts/ci/image_mount.sh
source "${SCRIPT_DIR}/image_mount.sh"

IMG="${1:?usage: chroot_checks.sh <image> [variant]}"
VARIANT="${2:-lite}"

IMPORTS_FILE="${SCRIPT_DIR}/imports.d/${VARIANT}.txt"
[[ -f "$IMPORTS_FILE" ]] || fail "imports list not found: $IMPORTS_FILE"

command -v qemu-aarch64-static >/dev/null 2>&1 || [[ -f /usr/bin/qemu-aarch64-static ]] \
    || fail "qemu-user-static is required (binfmt for arm64 chroot)"

ERRORS=0
c_fail() { echo -e "\x1B[31;1mCHECK FAIL: $*\x1B[0m" >&2; ERRORS=$((ERRORS + 1)); }

trap cleanup_image EXIT
mount_image "$IMG" rw   # rw: we drop qemu-aarch64-static in, removed on exit

# --- 1. the shipped /tmp, read before bind_system_mounts covers it ---
# bind_system_mounts puts a host tmpfs on $MNT/tmp so the checks below never
# depend on the image's free space. That is the right call for the checks and
# the wrong one for this question, so the image's own /tmp is read first.
log "Checking the shipped /tmp"
if [[ ! -d "$MNT/tmp" ]]; then
    c_fail "/tmp is missing from the image"
else
    tmp_mode="$(stat -c '%a' "$MNT/tmp")"
    [[ "$tmp_mode" == "1777" ]] || c_fail "/tmp is mode $tmp_mode, expected 1777"
fi
# Reported, never failed: a released image is shrunk on purpose and the device
# grows the filesystem on first boot, so a small number here is by design. It
# is printed because it is the one value that says whether a shrunk image can
# still be written to, and no run so far has recorded it.
log "Image rootfs free space: $(df -h --output=avail "$MNT" | tail -1 | tr -d ' ')"

bind_system_mounts

# A failed copy leaves every arm64 exec below failing for a reason that reads
# like a defect in the image, so it is a hard failure and never silent.
cp /usr/bin/qemu-aarch64-static "$MNT/usr/bin/" \
    || fail "could not copy qemu-aarch64-static into the image"

in_image() {
    chroot "$MNT" /bin/bash -c "$*"
}

# run as the ovos user via --userspec (sudo inside a bare chroot needs /proc
# and a pty; --userspec needs neither)
as_ovos() {
    chroot --userspec=1000:1000 "$MNT" /bin/bash -c "export HOME=/home/ovos USER=ovos; $*"
}

VENV_PY="/home/ovos/.venvs/ovos/bin/python"

# --- 2. venv imports ---
log "Checking venv imports (${VARIANT})"
imports="$(grep -vE '^\s*(#|$)' "$IMPORTS_FILE" | tr '\n' ',' | sed 's/,$//;s/,/, /g')"
if ! as_ovos "$VENV_PY -c 'import $imports'"; then
    c_fail "venv imports: $imports"
fi

# --- 3. pip check ---
log "Running pip check"
if ! as_ovos "$VENV_PY -m pip check"; then
    c_fail "pip check reported broken requirements"
fi

# --- 4. every shipped unit's Exec* binaries exist in the image ---
# Resolved against the image rootfs (host systemd-analyze would resolve
# against the host); catches units pointing at files that were renamed or
# never installed (the vendoring-drift bug class).
log "Verifying systemd unit Exec targets"
while IFS= read -r unit; do
    # skip dangling alias symlinks (dbus-org.*.service pointing at masked units)
    [[ -e "$unit" ]] || continue
    exec_paths="$(grep -hoE '^Exec[a-zA-Z]*=-?[^ ]+' "$unit" | sed 's/^Exec[a-zA-Z]*=-?//' || true)"
    for p in $exec_paths; do
        [[ "$p" == /* ]] || continue
        if [[ ! -e "$MNT$p" ]]; then
            c_fail "unit $(basename "$unit"): Exec target missing in image: $p"
        fi
    done
done < <(find "$MNT/etc/systemd/system" "$MNT/home/ovos/.config/systemd/user" \
              -maxdepth 1 -name '*.service' 2>/dev/null)

rm -f "$MNT/usr/bin/qemu-aarch64-static"

[[ "$ERRORS" -eq 0 ]] || fail "$ERRORS check(s) failed"
log "Tier 2 OK"
