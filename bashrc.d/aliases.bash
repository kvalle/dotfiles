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
