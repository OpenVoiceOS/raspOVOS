alias ologs="tail -f /ramdisk/mycroft/!(bus.log)"

# OVOS Status: List OVOS-related systemd services
alias ovos-status="systemctl --user list-units | grep ovos"

# OVOS Freeze: Save installed OVOS and skill-related packages to requirements.txt
alias ovos-freeze="~/.venvs/ovos/bin/pip list --format=freeze | grep -E 'ovos-|skill-' > requirements.txt"

# OVOS Update: Update all OVOS and skill-related packages
alias ovos-update="~/.venvs/ovos/bin/pip install -c https://github.com/OpenVoiceOS/ovos-releases/raw/refs/heads/main/constraints-testing.txt -U --pre \$(pip list --format=freeze | grep -E 'ovos-|skill-' | cut -d '=' -f 1)"

# OVOS Outdated: List outdated OVOS and skill-related packages
alias ovos-outdated="~/.venvs/ovos/bin/pip list --outdated | grep -E 'ovos-|skill-'"

# OVOS Pip: Run pip commands with a constraints file
alias ovos-pip="~/.venvs/ovos/bin/pip install -c https://github.com/OpenVoiceOS/ovos-releases/raw/refs/heads/main/constraints-testing.txt"

# OVOS quick docs:
alias ovos-manual="~/.venvs/ovos/bin/ovos-docs-viewer technical"
alias ovos-skills-info="~/.venvs/ovos/bin/ovos-docs-viewer skills"
alias ovos-server-status="~/.venvs/ovos/bin/ovos-docs-viewer live-status"

alias ovos-help="/bin/bash ~/.cli_login.sh"

alias ovos-restart="systemctl --user restart ovos"