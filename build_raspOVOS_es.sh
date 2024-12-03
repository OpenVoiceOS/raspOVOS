#!/bin/bash
# Exit on error
# If something goes wrong just stop.
# it allows the user to see issues at once rather than having
# scroll back and figure out what went wrong.
set -e

# Activate the virtual environment
source /home/$USER/.venvs/ovos/bin/activate

echo "Installing Piper TTS..."
pip install ovos-tts-plugin-piper

echo "Downloading spanish vosk model..."
# Download and extract VOSK model
VOSK_DIR="/home/$USER/.local/share/vosk"
mkdir -p $VOSK_DIR
wget https://alphacephei.com/vosk/models/vosk-model-small-es-0.42.zip -P $VOSK_DIR
unzip -o $VOSK_DIR/vosk-model-small-es-0.42.zip -d $VOSK_DIR
rm $VOSK_DIR/vosk-model-small-es-0.42.zip

# download default piper voice for spanish
PIPER_DIR="/home/$USER/.local/share/piper_tts/carlfm-x-low"
VOICE_URL="https://github.com/rhasspy/piper/releases/download/v0.0.2/voice-es-carlfm-x-low.tar.gz"
VOICE_ARCHIVE="$PIPER_DIR/voice-es-carlfm-x-low.tar.gz"
mkdir -p "$PIPER_DIR"
echo "Downloading voice from $VOICE_URL ..."
wget "$VOICE_URL" -O "$VOICE_ARCHIVE"
tar -xvzf "$VOICE_ARCHIVE" -C "$PIPER_DIR"
rm "$VOICE_ARCHIVE"

echo "Creating system level mycroft.conf..."
mkdir -p /etc/mycroft

CONFIG_ARGS=""
# Loop through the MYCROFT_CONFIG_FILES variable and append each file to the jq command
IFS=',' read -r -a config_files <<< "$MYCROFT_CONFIG_FILES"
for file in "${config_files[@]}"; do
  CONFIG_ARGS="$CONFIG_ARGS /mounted-github-repo/$file"
done
# Execute the jq command and merge the files into mycroft.conf
jq -s 'reduce .[] as $item ({}; . * $item)' $CONFIG_ARGS > /etc/mycroft/mycroft.conf


echo "Ensuring permissions for $USER user..."
# Replace 1000:1000 with the correct UID:GID if needed
chown -R 1000:1000 /home/$USER

echo "Cleaning up apt packages..."
apt-get --purge autoremove -y && apt-get clean