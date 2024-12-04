#!/bin/bash
# Exit on error
# If something goes wrong just stop.
# it allows the user to see issues at once rather than having
# scroll back and figure out what went wrong.
set -e


# Define variables
URL="https://github.com/OscillateLabsLLC/ovos-rust-messagebus/releases/download/v1.0.0/ovos_messagebus-armv7-unknown-linux-gnueabihf.tar.gz"
BINARY_NAME="ovos_messagebus-armv7-unknown-linux-gnueabihf"
TARGET_DIR="/usr/libexec"

mkdir -p $TARGET_DIR

# Temporary directory for download and extraction
TEMP_DIR=$(mktemp -d)

# Clean up on exit
cleanup() {
    echo "Cleaning up..."
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

# Download the tar.gz file
echo "Downloading $URL..."
curl -L -o "$TEMP_DIR/ovos_messagebus.tar.gz" "$URL"

# Extract the tar.gz file
echo "Extracting archive..."
tar -xzf "$TEMP_DIR/ovos_messagebus.tar.gz" -C "$TEMP_DIR"

# Move the binary to the target directory
echo "Moving binary to $TARGET_DIR..."
mv "$TEMP_DIR/$BINARY_NAME" "$TARGET_DIR/ovos_rust_messagebus"

# Make the binary executable
echo "Setting executable permissions..."
chmod +x "$TARGET_DIR/ovos_rust_messagebus"

# Confirm success
echo "Installation complete! Binary installed at $TARGET_DIR/ovos_rust_messagebus"
