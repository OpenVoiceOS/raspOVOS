#!/bin/bash
# For each offline/hybrid lang build script that both runs
# `ovos-config autoconfigure` and installs a plugin package, assert the
# plugin install happens before autoconfigure runs. autoconfigure picks
# STT/TTS plugins for the generated mycroft.conf; if it runs first, the
# config can name a plugin the image never installs.
# Run locally with:
#   ./scripts/ci/check_plugin_before_autoconfigure.sh
set -euo pipefail

cd "$(dirname "$0")/../.."

fail=0

for f in lang_builds/offline/*.sh lang_builds/hybrid/*.sh; do
    conf_line=$(grep -n 'ovos-config autoconfigure' "$f" | head -n1 | cut -d: -f1 || true)
    [[ -z "$conf_line" ]] && continue

    install_line=$(grep -n 'uv pip install.*ovos-\(stt\|tts\)-plugin' "$f" | head -n1 | cut -d: -f1 || true)
    [[ -z "$install_line" ]] && continue

    if (( install_line > conf_line )); then
        echo "FAIL: $f installs its plugin (line $install_line) after autoconfigure (line $conf_line)"
        fail=1
    fi
done

if (( fail )); then
    exit 1
fi
echo "check_plugin_before_autoconfigure OK"
