#!/bin/bash
# Exit on error: stops the script immediately if any command fails.
set -e

# Install Rust using rustup
echo "Installing Rust..."

# Set RUSTUP_HOME and CARGO_HOME
export RUSTUP_HOME="/usr/bin"
export CARGO_HOME="/home/$USER/.cargo"
mkdir -p $CARGO_HOME

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --profile minimal --no-modify-path

echo "Installing librespot..."
usr/bin/cargo install librespot

# Install OVOS spotifyd hook script
echo "Installing spotifyd OCP hooks..."
SERVICE_PATH="/home/$USER/.config/systemd/user"
SERVICE_FILE="ovos-spotify.service"
HOOK_SCRIPT="/usr/libexec/ovos-librespot"
cp -v /mounted-github-repo/services/ovos-librespot "$HOOK_SCRIPT"
chmod +x "$HOOK_SCRIPT"

# Copy and configure the systemd service file
echo "Setting up the OVOS spotifyd systemd service..."
cp -v /mounted-github-repo/services/$SERVICE_FILE "$SERVICE_PATH/$SERVICE_FILE"
chmod 644 "$SERVICE_PATH/$SERVICE_FILE"

# Enable the service by creating a symbolic link
mkdir -p "$SERVICE_PATH/default.target.wants/"
ln -sf "$SERVICE_PATH/$SERVICE_FILE" "$SERVICE_PATH/default.target.wants/$SERVICE_FILE"

