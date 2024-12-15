#!/bin/bash
# Exit on error
# If something goes wrong just stop.
# it allows the user to see issues at once rather than having
# scroll back and figure out what went wrong.
set -e

# Activate the virtual environment
source /home/$USER/.venvs/ovos/bin/activate


echo "Setting up default wifi country..."
/usr/bin/raspi-config nonint do_wifi_country NL

echo "Caching pre-trained padatious intents..."
mkdir -p /home/$USER/.local/share/mycroft/intent_cache
cp -rv /mounted-github-repo/intent_cache/nl-NL /home/$USER/.local/share/mycroft/intent_cache/

echo "Installing Citrinet plugin..."
uv pip install --no-progress ovos-stt-plugin-citrinet

echo "Downloading dutch citrinet model..."
python /mounted-github-repo/packages/download_citrinet_nl.py
# since script was run as root, we need to move downloaded files
mkdir -p /home/ovos/.cache/huggingface/hub/
mv /root/.cache/huggingface/hub/models--neongeckocom--stt_nl_citrinet_512_gamma_0_25/ /home/ovos/.cache/huggingface/hub/models--neongeckocom--stt_nl_citrinet_512_gamma_0_25/

echo "Downloading dutch vosk model..."
# Download and extract VOSK model
VOSK_DIR="/home/$USER/.local/share/vosk"
mkdir -p $VOSK_DIR
wget https://alphacephei.com/vosk/models/vosk-model-small-nl-0.22.zip -P $VOSK_DIR
unzip -o $VOSK_DIR/vosk-model-small-nl-0.22.zip -d $VOSK_DIR
rm $VOSK_DIR/vosk-model-small-nl-0.22.zip


echo "Installing Piper TTS..."
uv pip install --no-progress ovos-tts-plugin-piper -c $CONSTRAINTS

# download default piper voice for dutch
PIPER_DIR="/home/$USER/.local/share/piper_tts/mls_5809-low"
VOICE_URL="https://github.com/rhasspy/piper/releases/download/v0.0.2/voice-nl-mls_5809-low.tar.gz"
VOICE_ARCHIVE="$PIPER_DIR/voice-nl-mls_5809-low.tar.gz"
mkdir -p "$PIPER_DIR"
echo "Downloading voice from $VOICE_URL..."
wget "$VOICE_URL" -O "$VOICE_ARCHIVE"
tar -xvzf "$VOICE_ARCHIVE" -C "$PIPER_DIR"
# if we remove the voice archive the plugin will think its missing and redownload voice on boot...
rm "$VOICE_ARCHIVE"
touch $VOICE_ARCHIVE


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