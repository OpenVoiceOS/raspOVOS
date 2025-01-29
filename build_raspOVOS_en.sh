#!/bin/bash
# Exit on error
# If something goes wrong just stop.
# it allows the user to see issues at once rather than having
# scroll back and figure out what went wrong.
set -e

# Activate the virtual environment
source /home/$USER/.venvs/ovos/bin/activate

echo "Copying overlays..."
sudo cp -rv /mounted-github-repo/overlays/en/* /

echo "Setting up default wifi country..."
/usr/bin/raspi-config nonint do_wifi_country US

echo "Installing Piper TTS..."
uv pip install --no-progress ovos-tts-plugin-piper -c $CONSTRAINTS

# TODO - compile minimal without bundled voices
#echo "Installing Mimic TTS (for G2P)"
#apt-get -y --no-install-recommends install gcc make pkg-config automake libtool libasound2-dev libicu-dev
#MIMIC_VERSION=1.2.0.2
#git clone --branch ${MIMIC_VERSION} https://github.com/MycroftAI/mimic.git --depth=1 /tmp/mimic
#cd /tmp/mimic
#./autogen.sh
#./configure --with-audio=alsa --enable-shared --prefix="$(pwd)"
#make
#make install
#rm -rf /tmp/mimic
#uv pip install --no-progress ovos-tts-plugin-mimic -c $CONSTRAINTS

# download default piper voice for english  (change this for other languages)
PIPER_DIR="/home/$USER/.local/share/piper_tts/voice-en-gb-alan-low"
VOICE_URL="https://github.com/rhasspy/piper/releases/download/v0.0.2/voice-en-gb-alan-low.tar.gz"
VOICE_ARCHIVE="$PIPER_DIR/voice-en-gb-alan-low.tar.gz"
mkdir -p "$PIPER_DIR"
echo "Downloading voice from $VOICE_URL..."
wget "$VOICE_URL" -O "$VOICE_ARCHIVE"
tar -xvzf "$VOICE_ARCHIVE" -C "$PIPER_DIR"
# if we remove the voice archive the plugin will think its missing and redownload voice on boot...
rm "$VOICE_ARCHIVE"
touch $VOICE_ARCHIVE

echo "Creating system level mycroft.conf..."
mkdir -p /etc/mycroft

echo "Ensuring permissions for $USER user..."
# Replace 1000:1000 with the correct UID:GID if needed
chown -R 1000:1000 /home/$USER

echo "Cleaning up apt packages..."
apt-get --purge autoremove -y && apt-get clean