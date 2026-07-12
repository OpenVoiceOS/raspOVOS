#!/bin/bash
# Lint every shell script in the repo: *.sh files plus extensionless scripts
# (overlays/**/usr/local/bin, usr/libexec) identified by a sh/bash shebang.
# Run locally with:
#   ./scripts/ci/run_shellcheck.sh
set -euo pipefail

cd "$(dirname "$0")/../.."

mapfile -t sh_files < <(find . -path ./.git -prune -o -name '*.sh' -print)
mapfile -t shebang_files < <(grep -rlI --exclude-dir=.git --exclude='*.sh' -m1 -E '^#!.*\b(ba)?sh\b' . || true)

# Gate at error severity for now; tighten to warning once the backlog is
# fixed (one directory per PR).
echo "Checking ${#sh_files[@]} *.sh files and ${#shebang_files[@]} shebang scripts"
shellcheck --severity=error "${sh_files[@]}" "${shebang_files[@]}"
echo "shellcheck OK"
