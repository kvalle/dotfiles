#! /bin/sh
set -e

echo "Starting setting up symlinks"

mkdir -p ~/.config

# Zsh
rm ~/.zprofile || true
ln -s ~/dotfiles/zprofile ~/.zprofile
rm ~/.zshrc || true
ln -s ~/dotfiles/zshrc ~/.zshrc

# Git (config, ignore, message, allowed_signers)
rm -rf ~/.config/git || true
ln -s ~/dotfiles/git ~/.config/git

# Python
mkdir -p ~/.config/python
rm -f ~/.config/python/pythonrc.py || true
ln -s ~/dotfiles/python/pythonrc.py ~/.config/python/pythonrc.py

# GHCi
mkdir -p ~/.config/ghci
rm -f ~/.config/ghci/ghci.conf || true
ln -s ~/dotfiles/ghci/ghci.conf ~/.config/ghci/ghci.conf

# Starship
rm -f ~/.config/starship.toml || true
ln -s ~/dotfiles/starship.toml ~/.config/starship.toml

# Lazygit
rm -rf ~/.config/lazygit || true
ln -s ~/dotfiles/lazygit ~/.config/lazygit

# Ghostty
rm -rf ~/.config/ghostty || true
ln -s ~/dotfiles/ghostty ~/.config/ghostty

# Atuin
rm -rf ~/.config/atuin || true
ln -s ~/dotfiles/atuin ~/.config/atuin

# cplt (AI agent sandbox)
mkdir -p ~/.config/cplt
rm -f ~/.config/cplt/config.toml || true
ln -s ~/dotfiles/cplt/config.toml ~/.config/cplt/config.toml

# OpenCode
mkdir -p ~/.config/opencode
rm -f ~/.config/opencode/opencode.jsonc || true
ln -s ~/dotfiles/opencode/opencode.jsonc ~/.config/opencode/opencode.jsonc
rm -f ~/.config/opencode/tui.jsonc || true
ln -s ~/dotfiles/opencode/tui.jsonc ~/.config/opencode/tui.jsonc

# Tealdeer
rm -rf ~/.config/tealdeer || true
ln -s ~/dotfiles/tealdeer ~/.config/tealdeer

# Tuxedo
rm -rf ~/.config/tuxedo || true
ln -s ~/dotfiles/tuxedo ~/.config/tuxedo

# Superfile
rm -f "$HOME/Library/Application Support/superfile/config.toml" || true
ln -s ~/dotfiles/superfile/config.toml "$HOME/Library/Application Support/superfile/config.toml"
rm -f "$HOME/Library/Application Support/superfile/hotkeys.toml" || true
ln -s ~/dotfiles/superfile/hotkeys.toml "$HOME/Library/Application Support/superfile/hotkeys.toml"

# Agent skills (opencode, claude, etc.)
mkdir -p ~/.agents
rm -rf ~/.agents/skills || true
ln -s ~/dotfiles/agents/skills ~/.agents/skills
rm -f ~/.agents/.skill-lock.json || true
ln -s ~/dotfiles/agents/.skill-lock.json ~/.agents/.skill-lock.json

# Zen Browser
ZEN_PROFILE=$(find "$HOME/Library/Application Support/zen/Profiles" -maxdepth 1 -name "*.Default (release)" -type d 2>/dev/null | head -1)
if [ -n "$ZEN_PROFILE" ]; then
    rm -f "$ZEN_PROFILE/user.js" || true
    ln -s ~/dotfiles/zen/user.js "$ZEN_PROFILE/user.js"
else
    echo "Zen profile not found, skipping"
fi

echo "Done setting up symlinks"
