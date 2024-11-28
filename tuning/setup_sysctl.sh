#!/bin/bash
# Exit on error
# If something goes wrong just stop.
# it allows the user to see issues at once rather than having
# scroll back and figure out what went wrong.
set -e


echo "Configuring sysctl..."

# Define the sysctl configuration file
SYSCTL_FILE="/etc/sysctl.d/99-ovos.conf"

# Sysctl options to apply
declare -A sysctl_options=(
    ["net.ipv4.tcp_slow_start_after_idle"]=0
    ["net.ipv4.tcp_tw_reuse"]=1
    ["net.core.netdev_max_backlog"]=50000
    ["net.ipv4.tcp_max_syn_backlog"]=30000
    ["net.ipv4.tcp_max_tw_buckets"]=2000000
    ["net.core.rmem_max"]=16777216
    ["net.core.wmem_max"]=16777216
    ["net.core.rmem_default"]=16777216
    ["net.core.wmem_default"]=16777216
    ["net.ipv4.tcp_rmem"]="4096 87380 16777216"
    ["net.ipv4.tcp_wmem"]="4096 65536 16777216"
    ["net.core.optmem_max"]=40960
    ["fs.inotify.max_user_instances"]=8192
    ["fs.inotify.max_user_watches"]=524288
)

# Create or update sysctl configuration
echo "# OVOS kernel tuning parameters" > "$SYSCTL_FILE"
for option in "${!sysctl_options[@]}"; do
    echo "$option = ${sysctl_options[$option]}" >> "$SYSCTL_FILE"
done

echo "Kernel tuning parameters applied. Configuration saved to $SYSCTL_FILE."


