# ===========================================================================
# zsh configuration
# Sources modules from ~/dotfiles/zsh/ in the correct order.
# ===========================================================================

# Homebrew (must be first — other tools depend on it)
[ -f /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"

# Environment, PATH, and exports
source ~/dotfiles/zsh/environment.sh

# Core shell behaviour
source ~/dotfiles/zsh/options.sh
source ~/dotfiles/zsh/completions.sh

# Shortcuts
source ~/dotfiles/zsh/aliases.sh

# Version managers (nvm, jenv) — lazy-loaded
source ~/dotfiles/zsh/lazy-loaders.sh

# Tool integrations (direnv, fzf, atuin, etc.)
source ~/dotfiles/zsh/tools.sh

# Colors (shared ANSI variables used by functions below)
source ~/dotfiles/zsh/colors.sh

# Custom functions
for f in ~/dotfiles/zsh/functions/*.sh; do
  source "$f"
done

# Plugins (must be near end)
source ~/dotfiles/zsh/plugins.sh

# Appearance must load after plugins that define mode-dependent styles.
source ~/dotfiles/zsh/appearance.sh

# Prompt (must be last)
eval "$(starship init zsh)"

# Preserve the TAB widget installed by shell integrations, then wrap it.
_tab_widget=${${(z)"$(bindkey -M emacs '^I')"}[2]}
if [[ $_tab_widget != _complete_parent_path ]]; then
  typeset -g _complete_parent_path_fallback=$_tab_widget
fi
unset _tab_widget
bindkey -M emacs '^I' _complete_parent_path
