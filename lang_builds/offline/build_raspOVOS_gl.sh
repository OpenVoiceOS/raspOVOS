#!/bin/bash
# Exit on error
# If something goes wrong just stop.
# it allows the user to see issues at once rather than having
# scroll back and figure out what went wrong.
set -e

## Intended to run on top of the raspOVOS FULL image
: "${OVOS_USER:=ovos}"
: "${CONSTRAINTS:=https://github.com/OpenVoiceOS/OpenVoiceOS/raw/refs/heads/main/constraints-alpha.txt}"

# start from hybrid image
bash /mounted-github-repo/lang_builds/hybrid/build_raspOVOS_gl.sh

# Activate the virtual environment
source /home/$OVOS_USER/.venvs/ovos/bin/activate
export UV_CONSTRAINT="${CONSTRAINTS:-}" PIP_CONSTRAINT="${CONSTRAINTS:-}"

echo "Configuring for target language..."
/home/$OVOS_USER/.venvs/ovos/bin/ovos-config autoconfigure --lang gl-ES --offline --female --platform rpi5

echo "Downloading zuazo whisper model ..."
python -c "from huggingface_hub import snapshot_download; repo_id = 'Jarbas/faster-whisper-base-gl-cv13'; file_path = snapshot_download(repo_id=repo_id); print(f'Downloaded {repo_id}')"
# since script was run as root, we need to move downloaded files
mv /root/.cache/huggingface/hub/models--Jarbas--faster-whisper-base-gl-cv13/ /home/ovos/.cache/huggingface/hub/models--Jarbas--faster-whisper-base-gl-cv13/

echo "Ensuring permissions for $OVOS_USER user..."
# Replace 1000:1000 with the correct UID:GID if needed
chown -R 1000:1000 /home/$OVOS_USER

echo "Updating build manifest..."
LANG_CODE=gl bash /mounted-github-repo/scripts/write_build_manifest.sh offline
