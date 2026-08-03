# ---------------------------------------------------------------------------
# Environment variables
# ---------------------------------------------------------------------------
export TZ='Europe/Oslo'
export EDITOR='vim'
export LG_CONFIG_FILE="$HOME/.config/lazygit/config.yml"
export TEALDEER_CONFIG_DIR="$HOME/.config/tealdeer"
export BAT_THEME="Catppuccin Macchiato"
export EZA_CONFIG_DIR="$HOME/.config/eza"
export TODO_DIR="$HOME/.todos"
export TODO_FILE="$TODO_DIR/todo.txt"
export DONE_FILE="$TODO_DIR/done.txt"

# ---------------------------------------------------------------------------
# PATH
# ---------------------------------------------------------------------------
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/dotfiles/bin:$PATH"
export PATH="/Applications/Sublime Text.app/Contents/SharedSupport/bin:$PATH"
export PATH="/Applications/IntelliJ IDEA.app/Contents/MacOS:$PATH"
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="$HOME/.jenv/bin:$PATH"
export PATH="/usr/local/opt/python/libexec/bin:$PATH"

# ---------------------------------------------------------------------------
# Android
# ---------------------------------------------------------------------------
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$PATH"

# ---------------------------------------------------------------------------
# Python
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
