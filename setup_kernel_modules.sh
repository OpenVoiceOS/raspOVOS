#!/bin/bash
# Exit on error
# If something goes wrong just stop.
# it allows the user to see issues at once rather than having
# scroll back and figure out what went wrong.
set -e


echo "Configuring I2C, SPI, and I2S kernel modules..."

# Enable I2C, SPI, and I2S in /boot/config.txt
CONFIG_FILE="/boot/config.txt"

declare -A dtparams=(
    ["dtparam=i2c_arm"]="on"
    ["dtparam=spi"]="on"
    ["dtparam=i2s"]="on"
)

for key in "${!dtparams[@]}"; do
    value="${dtparams[$key]}"
    if grep -q "^${key}=" "$CONFIG_FILE"; then
        sed -i "s|^${key}=.*|${key}=${value}|" "$CONFIG_FILE"
    else
        echo "${key}=${value}" >> "$CONFIG_FILE"
    fi
done

echo "Kernel modules and Device Tree parameters configured."
