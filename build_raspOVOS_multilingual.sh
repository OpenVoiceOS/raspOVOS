#!/bin/bash
# Exit on error
# If something goes wrong just stop.
# it allows the user to see issues at once rather than having
# scroll back and figure out what went wrong.
set -e

: "${OVOS_USER:=ovos}"
: "${CONSTRAINTS:=https://github.com/OpenVoiceOS/ovos-releases/raw/refs/heads/main/constraints-alpha.txt}"

# Activate the virtual environment
source /home/$OVOS_USER/.venvs/ovos/bin/activate

echo "Copying overlays..."
sudo cp -rv /mounted-github-repo/overlays/en/* /
sudo cp -rv /mounted-github-repo/overlays/multi/* /

echo "Installing Plugins..."
# TODO: find offline multilingual model
# google is here as placeholder as we dont want to load too many piper voices into memory
uv pip install --no-progress ovos-tts-plugin-google-tx -c $CONSTRAINTS

echo "Ensuring permissions for $OVOS_USER user..."
# Replace 1000:1000 with the correct UID:GID if needed
chown -R 1000:1000 /home/$OVOS_USER

echo "Cleaning up apt packages..."
apt-get --purge autoremove -y && apt-get clean