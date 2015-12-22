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

alias tree2='tree -L 2'
alias tree3='tree -L 3'
alias tree4='tree -L 4'

# alias for "ESC + c"
#alias cls='echo -en "\33c"' 
alias cls='echo -en "\ec"'
#alias cls='clear && echo -en "\e[3J"' # for KDE
