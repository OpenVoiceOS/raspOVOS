#!/bin/bash
# Exit on error
# If something goes wrong just stop.
# it allows the user to see issues at once rather than having
# scroll back and figure out what went wrong.
set -e


echo "Installing CPU governor"

apt-get install -y --no-install-recommends linux-cpupower

# Configure the CPU governor to "performance"
CONFIG_FILE="/etc/default/cpupower"
if [[ -f "$CONFIG_FILE" ]]; then
    sed -i 's/^CPU_DEFAULT_GOVERNOR=.*/CPU_DEFAULT_GOVERNOR="performance"/' "$CONFIG_FILE"
else
    echo 'CPU_DEFAULT_GOVERNOR="performance"' > "$CONFIG_FILE"
fi

# Create the cpu governor systemd service file
cp -v /mounted-github-repo/cpu-governor.service /etc/systemd/system/cpu-governor.service
# Set permissions, enable, and start the service
chmod 644 /etc/systemd/system/cpu-governor.service
# enable service without using systemctl
ln -s /etc/systemd/system/cpu-governor.service /etc/systemd/system/multi-user.target.wants/cpu-governor.service

echo "CPU governor set to performance and service enabled"
