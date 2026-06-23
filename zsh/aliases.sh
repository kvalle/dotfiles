# ---------------------------------------------------------------------------
# Aliases
# ---------------------------------------------------------------------------

alias _ls='command ls -G'
alias ls='eza'
alias l='eza -1 --icons --git'
alias ll='eza -l --icons --git'
alias la='eza -la --icons --git'
alias lt='eza --tree --level=2 --icons'

alias path='echo -e ${PATH//:/\\n}'
alias tree2='eza --tree --level=2 --icons'
alias tree3='eza --tree --level=3 --icons'
alias tree4='eza --tree --level=4 --icons'

alias containerclean="docker ps -a -q | xargs docker rm"
alias imageclean="docker images --filter dangling=true -q | xargs docker rmi"

alias cls='echo -en "\ec"'
alias dns-flush='sudo killall -HUP mDNSResponder'
alias ukenummer='date +%V'

alias k="kubectl"
alias kge="kubectl get events --sort-by=.metadata.creationTimestamp"

alias lg="lazygit"
alias idea.='idea . > /dev/null 2>&1 &'

alias ghcr-login='op read "op://Private/6xakv5v7dwpp5d64dl5lxdijae/password" | docker login ghcr.io -u kvalle --password-stdin'

# Digipost
alias ts-fiks="dgp-stop-tailscale; dgp-tailscale"
alias ts-kill="dp az-tailscale kill-all"
