# ===========================================================================
# zsh configuration - no oh-my-zsh
# ===========================================================================

# ---------------------------------------------------------------------------
# Homebrew (must be early, other tools depend on it)
# ---------------------------------------------------------------------------
[ -f /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"

# ---------------------------------------------------------------------------
# Core zsh options
# ---------------------------------------------------------------------------
setopt AUTO_CD              # cd by typing directory name
setopt CORRECT              # suggest corrections for commands
setopt NO_CASE_GLOB         # case-insensitive globbing
setopt EXTENDED_GLOB        # extended glob patterns

# History
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY        # share history across sessions
setopt HIST_IGNORE_DUPS     # don't store duplicates
setopt HIST_IGNORE_SPACE    # don't store commands starting with space
setopt HIST_REDUCE_BLANKS   # remove extra blanks

# ---------------------------------------------------------------------------
# Completion system (replaces oh-my-zsh completion)
# ---------------------------------------------------------------------------
autoload -Uz compinit
# Only regenerate .zcompdump once per day
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # case-insensitive
zstyle ':completion:*' menu select                          # menu selection
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"     # colored completions
zstyle ':completion:*' special-dirs true                     # complete . and ..

# ---------------------------------------------------------------------------
# Environment
# ---------------------------------------------------------------------------
export TZ='Europe/Oslo'
export EDITOR='vim'

# ---------------------------------------------------------------------------
# PATH
# ---------------------------------------------------------------------------
export PATH="$HOME/dotfiles/bin:$PATH"
export PATH="/Applications/Sublime Text.app/Contents/SharedSupport/bin:$PATH"
export PATH="/Applications/IntelliJ IDEA.app/Contents/MacOS:$PATH"
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="$HOME/.jenv/bin:$PATH"
export PATH="/usr/local/opt/python/libexec/bin:$PATH"

# ---------------------------------------------------------------------------
# Aliases
# ---------------------------------------------------------------------------

alias ls='ls -G'
alias ll='ls -lh'
alias la='ls -lAh'
alias l='ls -lah'

alias path='echo -e ${PATH//:/\\n}'
alias tree2='tree -L 2'
alias tree3='tree -L 3'
alias tree4='tree -L 4'

alias containerclean="docker ps -a -q | xargs docker rm"
alias imageclean="docker images --filter dangling=true -q | xargs docker rmi"

alias cls='echo -en "\ec"'
alias dns-flush='sudo killall -HUP mDNSResponder'
alias ukenummer='date +%V'

alias k="kubectl"
alias kge="kubectl get events --sort-by=.metadata.creationTimestamp"

alias idea.='idea . > /dev/null 2>&1 &'

alias ghcr-login='op read "op://Private/6xakv5v7dwpp5d64dl5lxdijae/password" | docker login ghcr.io -u kvalle --password-stdin'

# Digipost
alias cddp="cd $HOME/code/digipost"
alias ts-fiks="dgp-stop-tailscale; dgp-tailscale"
alias ts-kill="dp az-tailscale kill-all"

# ---------------------------------------------------------------------------
# Lazy-loaded version managers
# ---------------------------------------------------------------------------

# nvm - only loaded when you call nvm, node, npm, npx, etc.
export NVM_DIR="$HOME/.nvm"
_lazy_nvm() {
  unfunction nvm node npm npx 2>/dev/null
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}
nvm()  { _lazy_nvm; nvm "$@" }
node() { _lazy_nvm; node "$@" }
npm()  { _lazy_nvm; npm "$@" }
npx()  { _lazy_nvm; npx "$@" }

# pyenv - only loaded when you call pyenv or python
_lazy_pyenv() {
  unfunction pyenv python python3 pip pip3 2>/dev/null
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
}
pyenv()   { _lazy_pyenv; pyenv "$@" }
python()  { _lazy_pyenv; python "$@" }
python3() { _lazy_pyenv; python3 "$@" }
pip()     { _lazy_pyenv; pip "$@" }
pip3()    { _lazy_pyenv; pip3 "$@" }

# jenv
eval "$(jenv init -)"

# sdkman - only loaded when you call sdk
export SDKMAN_DIR=/opt/homebrew/opt/sdkman-cli/libexec
_lazy_sdkman() {
  unfunction sdk 2>/dev/null
  [[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"
}
sdk() { _lazy_sdkman; sdk "$@" }

# ---------------------------------------------------------------------------
# Tools (fast inits only)
# ---------------------------------------------------------------------------

# direnv
eval "$(direnv hook zsh)"

# thefuck
eval $(thefuck --alias fix)

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# kubectl completion (cached, regenerated daily)
_kubectl_comp=~/.zsh_kubectl_completion
if [[ ! -f "$_kubectl_comp" ]] || [[ -n "$_kubectl_comp"(#qN.mh+24) ]]; then
  kubectl completion zsh > "$_kubectl_comp"
fi
source "$_kubectl_comp"
unset _kubectl_comp

# ssh (use macOS Keychain instead of spawning new agents)
ssh-add --apple-use-keychain 2>/dev/null

# ---------------------------------------------------------------------------
# Python config
# ---------------------------------------------------------------------------
export PYTHONSTARTUP=~/.config/python/pythonrc.py
export WORKON_HOME=~/pyenvs

# ---------------------------------------------------------------------------
# Ruby
# ---------------------------------------------------------------------------
export LDFLAGS="-L/opt/homebrew/opt/ruby/lib"
export CPPFLAGS="-I/opt/homebrew/opt/ruby/include"
export PKG_CONFIG_PATH="/opt/homebrew/opt/ruby/lib/pkgconfig"

# ---------------------------------------------------------------------------
# Digipost
# ---------------------------------------------------------------------------
export DIGIPOST_HOME=$HOME/code/digipost
source ~/.digipostrc
export DIGIPOST_SETTINGSXML_GITHUB_USERNAME='kvalle'
# Secret loaded from ~/.secrets (not version controlled)
# Populate with: op read 'op://Private/Digipost GitHub secret/password' --account my.1password.com > ~/.secrets/digipost-github-secret
[[ -f ~/.secrets/digipost-github-secret ]] && \
  export DIGIPOST_SETTINGSXML_GITHUB_SECRET="$(cat ~/.secrets/digipost-github-secret)"

export AZURE_USER="developer.kjetil.valle"
export AZURE_PASSWORD_STORE_DIR="$DPOST_REPOS_PATH/azure-passwords"

# ---------------------------------------------------------------------------
# Custom functions
# ---------------------------------------------------------------------------
for f in ~/dotfiles/functions/*.sh; do
  source "$f"
done

# ---------------------------------------------------------------------------
# Plugins (must be near end of file)
# ---------------------------------------------------------------------------
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ---------------------------------------------------------------------------
# Prompt - Starship (must be last)
# ---------------------------------------------------------------------------
eval "$(starship init zsh)"
