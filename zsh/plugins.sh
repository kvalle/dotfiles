# ---------------------------------------------------------------------------
# Plugins (must be near end, before prompt)
# ---------------------------------------------------------------------------
# Deliberately unguarded: if a plugin is missing, the error names the file,
# which beats silently losing autosuggestions and syntax highlighting.
source "$HOME/.local/state/nix/profiles/dotfiles/share/dotfiles/zsh-plugins/zsh-autosuggestions.zsh"
source "$HOME/.local/state/nix/profiles/dotfiles/share/dotfiles/zsh-plugins/zsh-syntax-highlighting.zsh"
