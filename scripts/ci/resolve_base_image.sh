#!/bin/bash
# Resolve the download URL of the newest raspOVOS base image release whose
# tag starts with the given prefix. Used by the full/lang workflows instead
# of hardcoded release URLs; pass an explicit URL via workflow input to
# reproduce an old build.
#
# Usage: resolve_base_image.sh <tag-prefix> [repo]
#   e.g. resolve_base_image.sh raspOVOS-DEV-bookworm-arm64-lite
# Prints the .img.xz asset URL of the newest matching release.
# Needs: curl, jq. GITHUB_TOKEN honoured if set (rate limits).

set -euo pipefail

PREFIX="${1:?usage: resolve_base_image.sh <tag-prefix> [repo]}"
REPO="${2:-OpenVoiceOS/raspOVOS}"

auth=()
[[ -n "${GITHUB_TOKEN:-}" ]] && auth=(-H "Authorization: token ${GITHUB_TOKEN}")

url="$(curl -sf "${auth[@]}" \
    "https://api.github.com/repos/${REPO}/releases?per_page=100" \
    | jq -r --arg p "$PREFIX" '
        [ .[] | select(.tag_name | startswith($p)) ]
        | sort_by(.created_at) | reverse | .[0].assets // []
        | map(select(.name | endswith(".img.xz"))) | .[0].browser_download_url // empty
    ')"

if [[ -z "$url" ]]; then
    echo "ERROR: no release with tag prefix '$PREFIX' and an .img.xz asset found in $REPO" >&2
    exit 1
fi
echo "$url"
