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
HIST_STAMPS="yyyy-mm-dd"

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

# ---------------------------------------------------------------------------
# Environment
# ---------------------------------------------------------------------------
export TZ='Europe/Oslo'
export ANSIBLE_NOCOWS=1

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='vim'
fi

# ---------------------------------------------------------------------------
# PATH (deduplicated)
# ---------------------------------------------------------------------------
export PATH="$HOME/dotfiles/bin:$PATH"
export PATH="/Applications/Sublime Text.app/Contents/SharedSupport/bin:$PATH"
export PATH="/Applications/IntelliJ IDEA.app/Contents/MacOS:$PATH"
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="$HOME/.jenv/bin:$PATH"
export PATH="/usr/local/opt/python/libexec/bin:$PATH"
export PATH="/usr/local/opt/postgresql@11/bin:$PATH"

# ---------------------------------------------------------------------------
# Aliases
# ---------------------------------------------------------------------------

# ls (previously from oh-my-zsh)
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
alias cddp="cd /Users/kjetil/code/digipost"
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

# jenv - only loaded when you call jenv or java
_lazy_jenv() {
  unfunction jenv java javac 2>/dev/null
  eval "$(jenv init -)"
}
jenv()  { _lazy_jenv; jenv "$@" }
java()  { _lazy_jenv; java "$@" }
javac() { _lazy_jenv; javac "$@" }

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

# thefuck (once, not twice)
eval $(thefuck --alias fix)

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# kubectl completion
source <(kubectl completion zsh)

# ssh-agent
{ eval $(ssh-agent); ssh-add -A; } &>/dev/null

# ---------------------------------------------------------------------------
# Python config
# ---------------------------------------------------------------------------
export PYTHONSTARTUP=~/.pythonrc.py
export WORKON_HOME=~/pyenvs

if [ -f /usr/local/bin/virtualenvwrapper.sh ]; then
  source /usr/local/bin/virtualenvwrapper.sh

  has_virtualenv() {
    if [ -e .venv ]; then
      workon $(cat .venv)
    fi
  }

  venv_cd () {
    cd "$@" && has_virtualenv
  }
  alias cd="venv_cd"
fi

# ---------------------------------------------------------------------------
# Ruby
# ---------------------------------------------------------------------------
export LDFLAGS="-L/opt/homebrew/opt/ruby/lib"
export CPPFLAGS="-I/opt/homebrew/opt/ruby/include"
export PKG_CONFIG_PATH="/opt/homebrew/opt/ruby/lib/pkgconfig"

# ---------------------------------------------------------------------------
# Digipost
# ---------------------------------------------------------------------------
export DIGIPOST_HOME=/Users/kjetil/code/digipost
source ~/.digipostrc
export DIGIPOST_SETTINGSXML_GITHUB_USERNAME='kvalle'
export DIGIPOST_SETTINGSXML_GITHUB_SECRET='{ZnBreDw2e7UHg7HQO7O3ej5aCIb5wtI2g0MQoaIoVMK8PkrPapsEhvlR5Eo4RqWScl+/FoBN+f0qyaRn9+tqMQ==}'

export AZURE_USER="developer.kjetil.valle"
export AZURE_PASSWORD_STORE_DIR="$DPOST_REPOS_PATH/azure-passwords"

# ---------------------------------------------------------------------------
# Custom functions
# ---------------------------------------------------------------------------
source ~/dotfiles/functions/git.sh

# ---------------------------------------------------------------------------
# Plugins (must be near end of file)
# ---------------------------------------------------------------------------
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ---------------------------------------------------------------------------
# Prompt - Starship (must be last)
# ---------------------------------------------------------------------------
eval "$(starship init zsh)"
