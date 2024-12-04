#!/bin/bash
# Exit on error: stops the script immediately if any command fails.
set -e

# Define variables
SPOTIFYD_URL="https://github.com/Spotifyd/spotifyd/releases/download/v0.3.5/spotifyd-linux-armhf-full.tar.gz"
SPOTIFYD_BIN="/home/$USER/.local/bin/spotifyd"
SERVICE_PATH="/home/$USER/.config/systemd/user"
SERVICE_FILE="ovos-spotify.service"
HOOK_SCRIPT="/usr/libexec/ovos-spotifyd"

# Create necessary directories
mkdir -p "$(dirname "$SPOTIFYD_BIN")" "$SERVICE_PATH/default.target.wants/"

# TODO - install from branch for bugfixes https://github.com/eladyn/spotifyd/tree/deps_upgrade
# Download and install spotifyd
echo "Downloading and installing spotifyd..."
curl -L "$SPOTIFYD_URL" | tar -xz -C "$(dirname "$SPOTIFYD_BIN")" --strip-components=1 spotifyd
chmod +x "$SPOTIFYD_BIN"

# Install OVOS spotifyd hook script
echo "Installing spotifyd OCP hooks..."
cp -v /mounted-github-repo/services/ovos-spotifyd "$HOOK_SCRIPT"
chmod +x "$HOOK_SCRIPT"

# Copy and configure the systemd service file
echo "Setting up the OVOS spotifyd systemd service..."
cp -v /mounted-github-repo/services/$SERVICE_FILE "$SERVICE_PATH/$SERVICE_FILE"
chmod 644 "$SERVICE_PATH/$SERVICE_FILE"

# Enable the service by creating a symbolic link
ln -sf "$SERVICE_PATH/$SERVICE_FILE" "$SERVICE_PATH/default.target.wants/$SERVICE_FILE"

