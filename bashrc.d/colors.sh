# add some colors to the world
if [ -x /usr/bin/dircolors ]; then
    # use colors as default
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'

    # setting the LS_COLORS envvar
    if [ -r ~/.dircolors ]; then
        eval "$(dircolors -b ~/.dircolors)"
    else
        eval "$(dircolors -b)"
    fi
fi
