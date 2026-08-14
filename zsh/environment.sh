# ---------------------------------------------------------------------------
# Environment variables
# ---------------------------------------------------------------------------
export TZ='Europe/Oslo'
export EDITOR='vim'
export TEALDEER_CONFIG_DIR="$HOME/.config/tealdeer"
export EZA_CONFIG_DIR="$HOME/.config/eza"
# Keep completion and eza file kinds on the terminal's active ANSI palette.
export LS_COLORS='fi=0:di=34;1:ln=36:pi=90:so=35:bd=31:cd=31:ex=32;1:or=31;1'
export TODO_DIR="$HOME/.todos"
export TODO_FILE="$TODO_DIR/todo.txt"
export DONE_FILE="$TODO_DIR/done.txt"

# ---------------------------------------------------------------------------
# PATH
# ---------------------------------------------------------------------------
typeset -U path PATH
export PATH="$HOME/.local/bin:$PATH"
export PATH="$DOTFILES/bin:$PATH"
export PATH="/Applications/Sublime Text.app/Contents/SharedSupport/bin:$PATH"
export PATH="/Applications/IntelliJ IDEA.app/Contents/MacOS:$PATH"
# $HOMEBREW_PREFIX comes from `brew shellenv` in zshrc; empty if brew is absent.
# This line must stay above the Nix profile below: both prepend, so whichever
# comes last wins, and Nix is meant to win for packages found in both places.
[[ -n "$HOMEBREW_PREFIX" ]] && export PATH="$HOMEBREW_PREFIX/opt/ruby/bin:$PATH"
export PATH="$HOME/.jenv/bin:$PATH"
# Kept in sync by hand with $DOTFILES_NIX_PROFILE in scripts/lib/common.sh,
# which this file cannot source: it is bash-only and would drag its helpers into
# every interactive shell.
export PATH="$HOME/.local/state/nix/profiles/dotfiles/bin:$PATH"

# ---------------------------------------------------------------------------
# Android
# ---------------------------------------------------------------------------
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$PATH"

# ---------------------------------------------------------------------------
# Python
# ---------------------------------------------------------------------------
export PYTHONSTARTUP=~/.config/python/pythonrc.py

# ---------------------------------------------------------------------------
# Ruby
# ---------------------------------------------------------------------------
# Build flags for the brew-installed Ruby. Pointless without brew, so they are
# skipped entirely rather than expanding to /opt/ruby/... with an empty prefix.
if [[ -n "$HOMEBREW_PREFIX" ]]; then
  export LDFLAGS="-L$HOMEBREW_PREFIX/opt/ruby/lib"
  export CPPFLAGS="-I$HOMEBREW_PREFIX/opt/ruby/include"
  export PKG_CONFIG_PATH="$HOMEBREW_PREFIX/opt/ruby/lib/pkgconfig"
fi

# ---------------------------------------------------------------------------
# Digipost
# ---------------------------------------------------------------------------
# ~/.digipostrc is not version controlled here; it comes from the Digipost
# specific dotfiles setup. Its presence is what marks this as a work machine,
# so the whole block is conditional on it: on a machine without it, none of
# these variables should exist at all.
if [[ -f ~/.digipostrc ]]; then
  # Must be set before sourcing .digipostrc, which reads this value.
  export DIGIPOST_HOME=$HOME/code/digipost
  source ~/.digipostrc

  export DIGIPOST_SETTINGSXML_GITHUB_USERNAME='kvalle'
  # Secret loaded from ~/.secrets (not version controlled)
  # Declared in secrets.conf, populated by scripts/secrets/setup.sh
  [[ -f ~/.secrets/digipost-github-secret ]] && \
    export DIGIPOST_SETTINGSXML_GITHUB_SECRET="$(cat ~/.secrets/digipost-github-secret)"

  export AZURE_USER="developer.kjetil.valle"
  # $DPOST_REPOS_PATH comes from .digipostrc, sourced above. Without the guard
  # it would be empty here and this would expand to /azure-passwords.
  export AZURE_PASSWORD_STORE_DIR="$DPOST_REPOS_PATH/azure-passwords"
fi
