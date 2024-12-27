#!/bin/bash
# Exit on error: stops the script immediately if any command fails.
set -e

# Install Rust using rustup
echo "Installing Rust..."

# Set RUSTUP_HOME and CARGO_HOME
export RUSTUP_HOME="/usr/bin"
export CARGO_HOME="/home/$USER/.cargo"
mkdir -p "$CARGO_HOME"

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --profile minimal --no-modify-path

# Source the Cargo environment to update PATH
source "$CARGO_HOME/env"

# Verify that Cargo is in the PATH
if ! command -v cargo &> /dev/null; then
    echo "Cargo could not be found. Please check the installation."
    exit 1
fi

echo "Installing librespot..."
cargo install librespot

