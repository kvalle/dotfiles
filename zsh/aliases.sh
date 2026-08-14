# ---------------------------------------------------------------------------
# Aliases
# ---------------------------------------------------------------------------

alias _ls='command ls -G'
alias ls='eza'
alias l='eza -1 --icons --git'
alias ll='eza -l --icons --git'
alias la='eza -la --icons --git'
alias lt='eza --tree --level=2 --icons=always'

alias path='echo -e ${PATH//:/\\n}'
alias tree='eza --tree --icons=always'
alias tree2='eza --tree --level=2 --icons=always'
alias tree3='eza --tree --level=3 --icons=always'
alias tree4='eza --tree --level=4 --icons=always'

alias containerclean="docker ps -a -q | xargs docker rm"
alias imageclean="docker images --filter dangling=true -q | xargs docker rmi"

alias cls='echo -en "\ec"'
alias dns-flush='sudo killall -HUP mDNSResponder'
alias ukenummer='date +%V'

alias k="kubectl"
alias kge="kubectl get events --sort-by=.metadata.creationTimestamp"

alias lg="lazygit"
alias tux="tuxedo"
alias idea.='idea .'

# Digipost
alias dpai="dp ai run claude"
