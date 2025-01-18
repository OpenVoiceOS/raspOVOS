# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w \$\[\033[00m\] '

alias ll='ls -la'

source .venvs/ovos/bin/activate

######################################################################
# Initialize OpenVoiceOS CLI Environment
######################################################################
. /usr/local/bin/ovos-logo
. /usr/local/bin/ovos-help

if [[ -f ~/.bash_aliases ]]; then
    source ~/.bash_aliases;
fi