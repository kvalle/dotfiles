# ===========================================================================
# zsh configuration
# Sources modules from ~/dotfiles/zsh/ in the correct order.
# ===========================================================================

# Homebrew (must be first — other tools depend on it)
[ -f /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"

# Core shell behaviour
source ~/dotfiles/zsh/options.sh
source ~/dotfiles/zsh/completions.sh

# Environment, PATH, and exports
source ~/dotfiles/zsh/environment.sh

# Shortcuts
source ~/dotfiles/zsh/aliases.sh

# Version managers (nvm, pyenv, jenv, sdkman) — lazy-loaded
source ~/dotfiles/zsh/lazy-loaders.sh

# Tool integrations (direnv, fzf, atuin, etc.)
source ~/dotfiles/zsh/tools.sh

# Custom functions
for f in ~/dotfiles/zsh/functions/*.sh; do
  source "$f"
done

# Plugins (must be near end)
source ~/dotfiles/zsh/plugins.sh

# Prompt (must be last)
eval "$(starship init zsh)"
