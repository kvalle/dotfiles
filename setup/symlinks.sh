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

# Ghostty
rm -rf ~/.config/ghostty || true
ln -s ~/dotfiles/ghostty ~/.config/ghostty

echo "Done setting up symlinks"
