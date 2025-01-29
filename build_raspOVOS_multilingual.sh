#!/bin/bash
# Exit on error
# If something goes wrong just stop.
# it allows the user to see issues at once rather than having
# scroll back and figure out what went wrong.
set -e

# Activate the virtual environment
source /home/$USER/.venvs/ovos/bin/activate

echo "Copying overlays..."
sudo cp -rv /mounted-github-repo/overlays/multi/* /

echo "Downloading whisper model..."
python -c "from huggingface_hub import snapshot_download; repo_id = 'Systran/faster-whisper-tiny'; file_path = snapshot_download(repo_id=repo_id); print(f'Downloaded {repo_id}'); print(file_path)"
# since script was run as root, we need to move downloaded files
mkdir -p /home/ovos/.cache/huggingface/hub/
mv /root/.cache/huggingface/hub/models--Systran--faster-whisper-tiny/ /home/ovos/.cache/huggingface/hub/models--Systran--faster-whisper-tiny/

echo "Installing Piper TTS..."
uv pip install --no-progress ovos-tts-plugin-piper -c $CONSTRAINTS


echo "Ensuring permissions for $USER user..."
# Replace 1000:1000 with the correct UID:GID if needed
chown -R 1000:1000 /home/$USER

echo "Cleaning up apt packages..."
apt-get --purge autoremove -y && apt-get clean