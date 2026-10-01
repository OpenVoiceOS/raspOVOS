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

# values reach python via the environment (quoted heredoc): no shell
# interpolation into python source, no quoting/injection hazards
M_PY_ABI="$(python3 -c 'import sys; print(f"cp{sys.version_info[0]}{sys.version_info[1]}")')"
M_OS_PRETTY="$(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2)"
M_BUILD_DATE="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
M_FROZEN="$("$VENV_PIP" freeze --all 2>/dev/null || true)"

M_RUN_URL=""
if [[ -n "${GITHUB_RUN_ID:-}" && -n "${GITHUB_REPOSITORY:-}" ]]; then
    M_RUN_URL="https://github.com/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}"
fi

export M_PY_ABI M_OS_PRETTY M_BUILD_DATE M_FROZEN M_RUN_URL VARIANT
export M_LANG="${LANG_CODE:-}" M_CONSTRAINTS="${CONSTRAINTS:-}" \
       M_BASE_URL="${BASE_IMAGE_URL:-}" M_SHA="${GITHUB_SHA:-}"

python3 - "$OUT" <<'PYEOF'
import json, os, sys
env = os.environ
manifest = {
    "variant": env["VARIANT"],
    "lang": env["M_LANG"],
    "build_date": env["M_BUILD_DATE"],
    "base_os": env["M_OS_PRETTY"],
    "python_abi": env["M_PY_ABI"],
    "constraints": env["M_CONSTRAINTS"],
    "base_image_url": env["M_BASE_URL"],
    "git_sha": env["M_SHA"],
    "workflow_run": env["M_RUN_URL"],
    "resolved_packages": env["M_FROZEN"].splitlines(),
}
with open(sys.argv[1], "w") as f:
    json.dump(manifest, f, indent=2, sort_keys=True)
print(f"Wrote {sys.argv[1]} ({len(manifest['resolved_packages'])} packages)")
PYEOF
chmod 644 "$OUT"
