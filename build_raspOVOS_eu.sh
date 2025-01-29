#!/bin/bash
# Exit on error
# If something goes wrong just stop.
# it allows the user to see issues at once rather than having
# scroll back and figure out what went wrong.
set -e

# Activate the virtual environment
source /home/$USER/.venvs/ovos/bin/activate

apt-get install -y cmake

echo "Copying overlays..."
sudo cp -rv /mounted-github-repo/overlays/eu/* /

echo "Setting up default wifi country..."
/usr/bin/raspi-config nonint do_wifi_country ES

echo "Downloading whisper model..."
python -c "from huggingface_hub import snapshot_download; repo_id = 'Jarbas/faster-whisper-tiny-eu-cv16'; file_path = snapshot_download(repo_id=repo_id); print(f'Downloaded {repo_id}'); print(file_path)"
# since script was run as root, we need to move downloaded files
mkdir -p /home/ovos/.cache/huggingface/hub/
mv /root/.cache/huggingface/hub/models--Jarbas--faster-whisper-tiny-eu-cv16/ /home/ovos/.cache/huggingface/hub/models--Jarbas--faster-whisper-tiny-eu-cv16/

echo "Installing AhoTTS"
uv pip install --no-progress ovos-tts-plugin-ahotts
git clone https://github.com/aholab/AhoTTS /tmp/AhoTTS
cd /tmp/AhoTTS
./script_compile_all_linux.sh
mv /tmp/AhoTTS/bin /usr/bin/AhoTTS/
cd ~

# TODO TTS and STT

echo "Ensuring permissions for $USER user..."
# Replace 1000:1000 with the correct UID:GID if needed
chown -R 1000:1000 /home/$USER

echo "Cleaning up apt packages..."
apt-get --purge autoremove -y && apt-get clean