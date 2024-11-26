#!/bin/bash
# Exit on error
# If something goes wrong just stop.
# it allows the user to see issues at once rather than having
# scroll back and figure out what went wrong.
set -e


echo "Copying wlan0-power systemd service to /etc/systemd/system/wlan0-power.service"
cp -v /mounted-github-repo/wlan0-power.service /etc/systemd/system/wlan0-power.service

# enable service without using systemctl
ln -s /etc/systemd/system/wlan0-power.service /etc/systemd/system/multi-user.target.wants/wlan0-power.service

echo "wlan0-power service is now enabled."

