# ---------------------------------------------------------------------------
# Plugins (must be near end, before prompt)
# ---------------------------------------------------------------------------
# Deliberately unguarded: if a plugin is missing, the error names the file,
# which beats silently losing autosuggestions and syntax highlighting.
source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
