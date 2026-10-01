#!/bin/bash
# Tier 1 — static image assertions.
# Loop-mounts a raspOVOS image read-only and runs the table-driven assertion
# lists under scripts/ci/assertions.d/. Add checks by adding lines to the
# tables, not by editing this script.
#
# Usage (root): scripts/ci/assert_image.sh <image[.xz]> [table ...]
#   default tables: common.txt (+ any extra table names passed, e.g. "gui")
# For self-tests, RASPOVOS_CI_ROOTFS=<dir> runs the assertions against an
# unpacked rootfs directory instead of loop-mounting an image (no root needed).
#
# Table syntax — one assertion per line, '#' comments allowed:
#   file_exists <path>            path exists (file, dir or symlink target)
#   file_absent <path>            path must NOT exist
#   symlink_valid <path>          symlink exists and its target resolves
#   unit_enabled <unit> <wantsdir> symlink for unit exists in the wants dir
#   user_exists <name> <uid>      /etc/passwd has name with uid
#   linger_enabled <user>         /var/lib/systemd/linger/<user> exists
#   json_valid <path>             file parses as JSON
#   grep_file <path> <regex>      file contains regex (extended)
# Paths are relative to the image rootfs.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=scripts/ci/image_mount.sh
source "${SCRIPT_DIR}/image_mount.sh"

IMG="${1:?usage: assert_image.sh <image|-> [table ...]}"
shift || true
TABLES=(common)
[[ $# -gt 0 ]] && TABLES+=("$@")

PASS=0
ERRORS=0

a_fail() { echo -e "\x1B[31;1mASSERT FAIL: $*\x1B[0m" >&2; ERRORS=$((ERRORS + 1)); }
a_pass() { PASS=$((PASS + 1)); }

check_line() {
    local op="$1"; shift
    case "$op" in
        file_exists)
            [[ -e "$MNT$1" || -L "$MNT$1" ]] && a_pass || a_fail "file_exists $1" ;;
        file_absent)
            [[ ! -e "$MNT$1" && ! -L "$MNT$1" ]] && a_pass || a_fail "file_absent $1 (exists)" ;;
        symlink_valid)
            if [[ -L "$MNT$1" ]]; then
                local target
                target="$(readlink "$MNT$1")"
                # absolute symlink targets point inside the image rootfs
                [[ "$target" == /* ]] && target="$MNT$target" || target="$(dirname "$MNT$1")/$target"
                [[ -e "$target" ]] && a_pass || a_fail "symlink_valid $1 -> $(readlink "$MNT$1") (dangling)"
            else
                a_fail "symlink_valid $1 (not a symlink)"
            fi ;;
        unit_enabled)
            local unit="$1" wants="$2"
            [[ -L "$MNT$wants/$unit" ]] && a_pass || a_fail "unit_enabled $unit ($wants)" ;;
        user_exists)
            grep -qE "^$1:[^:]*:$2:" "$MNT/etc/passwd" && a_pass || a_fail "user_exists $1 uid=$2" ;;
        linger_enabled)
            [[ -f "$MNT/var/lib/systemd/linger/$1" ]] && a_pass || a_fail "linger_enabled $1" ;;
        json_valid)
            python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$MNT$1" 2>/dev/null \
                && a_pass || a_fail "json_valid $1" ;;
        grep_file)
            local path="$1"; shift
            grep -qE "$*" "$MNT$path" 2>/dev/null && a_pass || a_fail "grep_file $path '$*'" ;;
        *)
            a_fail "unknown assertion op: $op" ;;
    esac
}

if [[ -n "${RASPOVOS_CI_ROOTFS:-}" ]]; then
    MNT="$RASPOVOS_CI_ROOTFS"
    [[ -d "$MNT" ]] || fail "RASPOVOS_CI_ROOTFS is not a directory: $MNT"
    log "Using rootfs directory: $MNT"
else
    trap cleanup_image EXIT
    mount_image "$IMG" ro
fi

for table in "${TABLES[@]}"; do
    table_file="${SCRIPT_DIR}/assertions.d/${table}.txt"
    [[ -f "$table_file" ]] || fail "assertion table not found: $table_file"
    log "Running assertions: ${table}.txt"
    while IFS= read -r line; do
        line="${line%%#*}"
        [[ -z "${line// /}" ]] && continue
        # shellcheck disable=SC2086
        check_line $line
    done < "$table_file"
done

log "Assertions passed: $PASS, failed: $ERRORS"
[[ "$ERRORS" -eq 0 ]] || fail "$ERRORS assertion(s) failed"
log "Tier 1 OK"
