#!/bin/bash
# Exit on error: stops the script immediately if any command fails.
set -e

cp -v /mounted-github-repo/tuning/wifi-connect.bin /usr/local/sbin/wifi-connect
cp -rv /mounted-github-repo/tuning/wifi-connect /usr/local/share/
