#!/bin/bash
# Exit on error: stops the script immediately if any command fails.
set -e

echo "Installing rust..."
curl https://sh.rustup.rs -sSf | sh -s -- -y

echo "Installing librespot..."
mkdir -p /home/ovos/.cargo
chown -R ovos:ovos /home/ovos/.cargo
CARGO_HOME=/home/ovos/.cargo cargo install librespot

# Define variables
SPOTIFYD_BIN="/home/$USER/.cargo/bin/spotifyd"
SERVICE_PATH="/home/$USER/.config/systemd/user"
SERVICE_FILE="ovos-spotify.service"
HOOK_SCRIPT="/usr/libexec/ovos-librespot"

# Install OVOS spotifyd hook script
echo "Installing spotifyd OCP hooks..."
cp -v /mounted-github-repo/services/ovos-librespot "$HOOK_SCRIPT"
chmod +x "$HOOK_SCRIPT"

# Copy and configure the systemd service file
echo "Setting up the OVOS spotifyd systemd service..."
cp -v /mounted-github-repo/services/$SERVICE_FILE "$SERVICE_PATH/$SERVICE_FILE"
chmod 644 "$SERVICE_PATH/$SERVICE_FILE"

# Enable the service by creating a symbolic link
mkdir -p "$SERVICE_PATH/default.target.wants/"
ln -sf "$SERVICE_PATH/$SERVICE_FILE" "$SERVICE_PATH/default.target.wants/$SERVICE_FILE"

