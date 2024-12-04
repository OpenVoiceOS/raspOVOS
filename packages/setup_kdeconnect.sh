#!/bin/bash
# Exit on error: stops the script immediately if any command fails.
set -e

apt-get install -y --no-install-recommends kdeconnect
cp -v /mounted-github-repo/services/kdeconnect.service /etc/systemd/system/kdeconnect.service
chmod 644 /etc/systemd/system/kdeconnect.service
ln -s /etc/systemd/system/kdeconnect.service /etc/systemd/system/multi-user.target.wants/kdeconnect.service
