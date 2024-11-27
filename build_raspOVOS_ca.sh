#!/bin/bash
# Exit on error
# If something goes wrong just stop.
# it allows the user to see issues at once rather than having
# scroll back and figure out what went wrong.
set -e


# Activate the virtual environment
source /home/$USER/.venvs/ovos/bin/activate

echo "Updating splashscreen..."
cp -v /mounted-github-repo/splashscreen.png /opt/ovos/splashscreen_ca.png

# install matxa
echo "Installing Matxa TTS..."
pip install ovos-tts-plugin-matxa-multispeaker-cat -c /etc/mycroft/constraints.txt
apt-get install -y automake libtool
git clone https://github.com/espeak-ng/espeak-ng.git /tmp/espeak-ng
cd /tmp/espeak-ng
./autogen.sh  && ./configure && make && make install
rm -rf /tmp/espeak-ng

echo "Downloading catalan vosk model..."
# Download and extract VOSK model
VOSK_DIR="/home/$USER/.local/share/vosk"
mkdir -p $VOSK_DIR
wget https://alphacephei.com/vosk/models/vosk-model-small-ca-0.4.zip -P $VOSK_DIR
unzip -o $VOSK_DIR/vosk-model-small-ca-0.4.zip -d $VOSK_DIR
rm $VOSK_DIR/vosk-model-small-ca-0.4.zip

# remove english piper voice
EN_PIPER_DIR="/home/$USER/.local/share/piper_tts/voice-en-gb-alan-low"
rm -rf "$EN_PIPER_DIR"

echo "Configuring mycroft.conf for catalan..."
cp -v /mounted-github-repo/mycroft_ca.conf /etc/mycroft/mycroft.conf

echo "Ensuring permissions for $USER user..."
# Replace 1000:1000 with the correct UID:GID if needed
chown -R 1000:1000 /home/$USER

echo "Cleaning up apt packages..."
apt-get --purge autoremove -y && apt-get clean