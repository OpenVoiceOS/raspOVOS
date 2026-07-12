#!/bin/bash
# Exit on error
# If something goes wrong just stop.
# it allows the user to see issues at once rather than having
# scroll back and figure out what went wrong.
set -e

: "${OVOS_USER:=ovos}"
: "${CONSTRAINTS:=https://github.com/OpenVoiceOS/OpenVoiceOS/raw/refs/heads/main/constraints-alpha.txt}"

# Activate the virtual environment
source /home/$OVOS_USER/.venvs/ovos/bin/activate
export UV_CONSTRAINT="${CONSTRAINTS:-}" PIP_CONSTRAINT="${CONSTRAINTS:-}"

# TODO - no wake word for "wake up"
#echo "Copying overlays..."
#sudo cp -rv /mounted-github-repo/overlays/fr/* /

echo "Setting up default wifi country..."
/usr/bin/raspi-config nonint do_wifi_country FR

echo "Configuring for target language..."
/home/$OVOS_USER/.venvs/ovos/bin/ovos-config autoconfigure --lang fr-FR --online --male --platform rpi3

echo "Ensuring permissions for $OVOS_USER user..."
# Replace 1000:1000 with the correct UID:GID if needed
chown -R 1000:1000 /home/$OVOS_USER

echo "Cleaning up apt packages..."
apt-get --purge autoremove -y && apt-get clean
echo "Updating build manifest..."
LANG_CODE=fr bash /mounted-github-repo/scripts/write_build_manifest.sh lite
