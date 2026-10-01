#!/bin/bash
# Install a prebuilt wheel listed in wheels.txt, selecting the row that
# matches the running python's ABI tag. Hard-fails with instructions when no
# matching wheel exists, so a Python version bump breaks the BUILD loudly
# instead of the booted image.
#
# Usage: install_wheel.sh <package> [wheels.txt path]
# Runs inside the image chroot with the OVOS venv activated (uv available).

set -euo pipefail

PKG="${1:?usage: install_wheel.sh <package> [wheels.txt]}"
WHEELS_FILE="${2:-/mounted-github-repo/wheels.txt}"

[[ -f "$WHEELS_FILE" ]] || { echo "ERROR: wheels file not found: $WHEELS_FILE" >&2; exit 1; }

ABI="$(python3 -c 'import sys; print(f"cp{sys.version_info[0]}{sys.version_info[1]}")')"

url="$(awk -v pkg="$PKG" -v abi="$ABI" \
    '$1 == pkg && $2 == abi { print $3; exit }' "$WHEELS_FILE")"

if [[ -z "$url" ]]; then
    cat >&2 <<EOF
ERROR: no prebuilt wheel for package '$PKG' with ABI '$ABI' in $WHEELS_FILE.
The base OS python version changed. Build an aarch64 wheel for $PKG against
$ABI (see ovos-binary-shop), publish it, and add a row to wheels.txt.
Available rows for $PKG:
$(awk -v pkg="$PKG" '$1 == pkg { print "  " $0 }' "$WHEELS_FILE")
EOF
    exit 1
fi

echo "Installing $PKG ($ABI) from $url"
uv pip install --no-progress "$url"
