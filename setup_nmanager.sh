#!/bin/bash
# Exit on error
# If something goes wrong just stop.
# it allows the user to see issues at once rather than having
# scroll back and figure out what went wrong.
set -e

echo "Configuring NetworkManager..."
mkdir -p /etc/polkit-1/rules.d/
mkdir -p /etc/NetworkManager/conf.d/
cp -v /mounted-github-repo/50-org.freedesktop.NetworkManager.rules /etc/polkit-1/rules.d/50-org.freedesktop.NetworkManager.rules
cp -v /mounted-github-repo/NetworkManager.conf /etc/NetworkManager/NetworkManager.conf
cp -v /mounted-github-repo/wifi-powersave-off.conf /etc/NetworkManager/conf.d/wifi-powersave-off.conf

