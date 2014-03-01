# If not running interactively, don't do anything
#[ -z "$PS1" ] && return

# Don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# Append to the history file, don't overwrite it
shopt -s histappend

# Allow alias expansion in non-interactive mode
shopt -s expand_aliases

# If set, Bash attempts to save all lines of a multiple-line command in the 
# same history entry. This allows easy re-editing of multi-line commands.
shopt -s cmdhist

# Increasing size of bash history.
# For setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=50000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, and Readline is being used, Bash will not attempt to search the PATH
# for possible completions when completion is attempted on an empty line.
shopt -s no_empty_cmd_completion

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# Include settings from other files
if [ -d ~/.bashrc.d ]; then
    for rc_file in ~/.bashrc.d/*.bash; do
        [ -x $rc_file ] && . $rc_file
    done
    unset rc_file
fi
