#!/bin/bash
# Exit on error
# If something goes wrong just stop.
# it allows the user to see issues at once rather than having
# scroll back and figure out what went wrong.
set -e


: "${OVOS_USER:=ovos}"
: "${CONSTRAINTS:=https://github.com/OpenVoiceOS/ovos-releases/raw/refs/heads/main/constraints-alpha.txt}"


# Retrieve the GID of the 'ovos' group
GROUP_FILE="/etc/group"
TGID=$(awk -F: -v group="ovos" '$1 == group {print $3}' "$GROUP_FILE")

# Check if GID was successfully retrieved
if [[ -z "$TGID" ]]; then
    echo "Error: Failed to retrieve GID for group 'ovos'. Exiting..."
    exit 1
fi

echo "The GID for 'ovos' is: $TGID"

# Parse the UID of the current user from /etc/passwd
PASSWD_FILE="/etc/passwd"
TUID=$(awk -F: -v user="$OVOS_USER" '$1 == user {print $3}' "$PASSWD_FILE")

# Check if UID was successfully retrieved
if [[ -z "$TUID" ]]; then
    echo "Error: Failed to retrieve UID for user '$OVOS_USER'. Exiting..."
    exit 1
fi

echo "The UID for '$OVOS_USER' is: $TUID"

# Copy raspOVOS overlay to the system.
echo "Copying raspOVOS (offline) overlay..."
cp -rv /mounted-github-repo/overlays/base_ovos_offline/* /

# Create and activate a virtual environment for OVOS.
echo "Entering virtual environment..."
source /home/$OVOS_USER/.venvs/ovos/bin/activate

echo "Installing llama.cpp"
uv pip install --no-progress https://github.com/abetlen/llama-cpp-python/releases/download/v0.3.2/llama_cpp_python-0.3.2-cp311-cp311-linux_aarch64.whl

echo "Downloading multilingual model2vec intent model ..."
python -c "from huggingface_hub import hf_hub_download; repo_id='Jarbas/ovos-model2vec-intents-LaBSE'; files=['model.safetensors', 'tokenizer.json', 'config.json']; [print(f'Downloaded {file} to {hf_hub_download(repo_id=repo_id, filename=file)}') for file in files]"
# since script was run as root, we need to move downloaded files
mkdir -p /home/ovos/.cache/huggingface/hub/
mv /root/.cache/huggingface/hub/models--Jarbas--ovos-model2vec-intents-LaBSE/ /home/ovos/.cache/huggingface/hub/models--Jarbas--ovos-model2vec-intents-LaBSE/

echo "Downloading whisper tiny model (for lang detection)..."
python -c "from huggingface_hub import snapshot_download; repo_id = 'Systran/faster-whisper-tiny'; file_path = snapshot_download(repo_id=repo_id); print(f'Downloaded {repo_id}')"
# since script was run as root, we need to move downloaded files
mv /root/.cache/huggingface/hub/models--Systran--faster-whisper-tiny/ /home/ovos/.cache/huggingface/hub/models--Systran--faster-whisper-tiny/
