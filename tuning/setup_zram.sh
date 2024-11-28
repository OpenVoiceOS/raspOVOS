#!/bin/bash
# Exit on error
# If something goes wrong just stop.
# it allows the user to see issues at once rather than having
# scroll back and figure out what went wrong.
set -e

# ZRAM
echo "Setting up ZRAM..."
apt-get install -y --no-install-recommends systemd-zram-generator

# Copy configuration
cp -v /mounted-github-repo/tuning/zram-generator.conf /etc/systemd/zram-generator.conf
SYSCTL_CONF="/etc/sysctl.d/98-zram.conf"

# Configure sysctl settings for ZRAM
echo "Applying sysctl settings for ZRAM..."
cat <<EOL | tee "$SYSCTL_CONF"
vm.swappiness=100
vm.page-cluster=0
vm.vfs_cache_pressure=500
vm.dirty_background_ratio=1
vm.dirty_ratio=50
EOL

# Manually enable the ZRAM service
ln -s /usr/lib/systemd/system/systemd-zram-setup@.service /etc/systemd/system/multi-user.target.wants/systemd-zram-setup@zram0.service

echo "ZRAM setup complete."
