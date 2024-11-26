alias ologs="tail -f /ramdisk/mycroft/!(bus.log)"

# OVOS Status: List OVOS-related systemd services
alias ovos-status="systemctl --user list-units | grep ovos"

# OVOS Freeze: Save installed OVOS and skill-related packages to requirements.txt
alias ovos-freeze="pip list --format=freeze | grep -E 'ovos-|skill-' > requirements.txt"

# OVOS Update: Update all OVOS and skill-related packages
alias ovos-update="pip install -U --pre \$(pip list --format=freeze | grep -E 'ovos-|skill-' | cut -d '=' -f 1)"

# OVOS Outdated: List outdated OVOS and skill-related packages
alias ovos-outdated="pip list --outdated | grep -E 'ovos-|skill-'"
