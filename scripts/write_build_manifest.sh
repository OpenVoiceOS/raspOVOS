#!/bin/bash
# Write /opt/ovos/build-manifest.json inside the image: everything needed to
# reproduce or debug this exact build. Runs at the END of provisioning (inside
# the chroot, venv available) so the frozen package list reflects what ships.
#
# Usage: write_build_manifest.sh <variant>
# Env consumed (all optional): CONSTRAINTS, BASE_IMAGE_URL, GITHUB_SHA,
# GITHUB_RUN_ID, GITHUB_REPOSITORY, LANG_CODE

set -euo pipefail

VARIANT="${1:?usage: write_build_manifest.sh <variant>}"
# MANIFEST_OUT/VENV_PIP overridable for self-tests
OUT="${MANIFEST_OUT:-/opt/ovos/build-manifest.json}"
VENV_PIP="${VENV_PIP:-/home/${OVOS_USER:-ovos}/.venvs/ovos/bin/pip}"

mkdir -p "$(dirname "$OUT")"

PY_ABI="$(python3 -c 'import sys; print(f"cp{sys.version_info[0]}{sys.version_info[1]}")')"
OS_PRETTY="$(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2)"
BUILD_DATE="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
FROZEN="$("$VENV_PIP" freeze --all 2>/dev/null | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read().splitlines()))')"

RUN_URL=""
if [[ -n "${GITHUB_RUN_ID:-}" && -n "${GITHUB_REPOSITORY:-}" ]]; then
    RUN_URL="https://github.com/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}"
fi

python3 - "$OUT" <<PYEOF
import json, sys
manifest = {
    "variant": "${VARIANT}",
    "lang": "${LANG_CODE:-}",
    "build_date": "${BUILD_DATE}",
    "base_os": "${OS_PRETTY}",
    "python_abi": "${PY_ABI}",
    "constraints": "${CONSTRAINTS:-}",
    "base_image_url": "${BASE_IMAGE_URL:-}",
    "git_sha": "${GITHUB_SHA:-}",
    "workflow_run": "${RUN_URL}",
    "resolved_packages": ${FROZEN},
}
with open(sys.argv[1], "w") as f:
    json.dump(manifest, f, indent=2, sort_keys=True)
print(f"Wrote {sys.argv[1]} ({len(manifest['resolved_packages'])} packages)")
PYEOF
chmod 644 "$OUT"
