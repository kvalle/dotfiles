alias ll='ls -lh'
alias la='ls -lAh'
alias lg='la | grep '
alias findg='find . | grep '
alias c=clear
alias ..='cd ..'
alias j='jobs -l'
alias more='less' # less is more
alias which='type -a'
alias path='echo -e ${PATH//:/\\n}'

# add some color to various commands
if [ -x /usr/bin/dircolors ]; then
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi
