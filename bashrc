# If not running interactively, don't do anything
#[ -z "$PS1" ] && return

# Don't put duplicates or lines beginning with spaces in the history.
HISTCONTROL=ignoredups:ignorespace

# Append to the history file, don't overwrite it.
shopt -s histappend

# Allow alias expansion in non-interactive mode.
shopt -s expand_aliases

# Save all lines of a multiple-line command in the same history entry.
shopt -s cmdhist

# Mores sensible settings for bash history size.
HISTSIZE=10000
HISTFILESIZE=$HISTSIZE

# Check the window size after each command and, if necessary, update the 
# values of LINES and COLUMNS.
shopt -s checkwinsize

# Enable recursive globbing with `**`:
shopt -s globstar 2>/dev/null

# If set, and Readline is being used, Bash will not attempt to search the PATH
# for possible completions when completion is attempted on an empty line.
shopt -s no_empty_cmd_completion

# Make sure programmable completion features is enabled.
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# Set default editor
export EDITOR=vim

# Include settings from other files
if [ -d ~/.bashrc.d ]; then
    for rc_file in ~/.bashrc.d/*.sh; do
        [ -x $rc_file ] && . $rc_file
    done
    unset rc_file
fi

# source nsb_env file
[[ -s ~/.nsb_env ]] && . ~/.nsb_env

export PATH="~/.bin:$PATH"
