#!/bin/bash
# Exit on error
# If something goes wrong just stop.
# it allows the user to see issues at once rather than having
# scroll back and figure out what went wrong.
set -e

# Activate the virtual environment
source /home/$USER/.venvs/ovos/bin/activate

echo "Copying overlays..."
sudo cp -rv /mounted-github-repo/overlays/gl/* /

echo "Setting up default wifi country..."
/usr/bin/raspi-config nonint do_wifi_country ES

echo "Downloading portuguese vosk model..."
# Download and extract VOSK model
VOSK_DIR="/home/$USER/.local/share/vosk"
mkdir -p $VOSK_DIR
wget https://alphacephei.com/vosk/models/vosk-model-small-pt-0.3.zip -P $VOSK_DIR
unzip -o $VOSK_DIR/vosk-model-small-pt-0.3.zip -d $VOSK_DIR
rm $VOSK_DIR/vosk-model-small-pt-0.3.zip

# TODO local cotovia / nos
uv pip install --no-progress ovos-tts-plugin-cotovia ovos-tts-plugin-cotovia-remote -c $CONSTRAINTS

echo "Ensuring permissions for $USER user..."
# Replace 1000:1000 with the correct UID:GID if needed
chown -R 1000:1000 /home/$USER

echo "Cleaning up apt packages..."
apt-get --purge autoremove -y && apt-get clean