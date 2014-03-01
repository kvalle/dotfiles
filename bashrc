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

# Set compose key to left "windows" key
if [ -f /usr/bin/setxkbmap ]; then
	setxkbmap -option compose:lwin
fi

# Include settings from other files
if [ -d ~/.bashrc.d ]; then
    for component in ~/.bashrc.d/*.bash; do
        [ -x $component ] && . $component
    done
    unset component
fi

# LESS man page colors (makes Man pages more readable).
export PAGER=less
export LESS_TERMCAP_mb=$'\E[01;31m' 
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

# Less cows from Ansible, please
export ANSIBLE_NOCOWS=1

# Some useful aliases
alias dunnet='emacs -batch -l dunnet'
alias subl=sublime_text
alias ll='ls -lh'
alias la='ls -lAh'
alias lg='la | grep '
alias findg='find . | grep '
alias c=clear
alias gief='sudo apt-get install'
alias ..='cd ..'
alias linode='ssh kjetil@kjetilvalle.com'
alias j='jobs -l'
alias which='type -a'
alias path='echo -e ${PATH//:/\\n}'
alias more='less' # less is more
alias serve="python -m SimpleHTTPServer"

# add some color to various commands
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi
