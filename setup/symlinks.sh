#! /bin/sh
set -e

echo "Starting setting up symlinks"

rm ~/.gitconfig || true
ln -s ~/dotfiles/gitconfig ~/.gitconfig

rm ~/.gitignore || true
ln -s ~/dotfiles/gitignore ~/.gitignore

rm ~/.pythonrc.py || true
ln -s ~/dotfiles/pythonrc.py ~/.pythonrc.py

rm ~/.ghci || true
ln -s ~/dotfiles/ghci ~/.ghci

rm ~/.zprofile || true
ln -s ~/dotfiles/zprofile ~/.zprofile

rm ~/.zshrc || true
ln -s ~/dotfiles/zshrc ~/.zshrc

mkdir -p ~/.config

rm ~/.config/starship.toml || true
ln -s ~/dotfiles/starship.toml ~/.config/starship.toml

rm -rf ~/.config/ghostty || true
ln -s ~/dotfiles/ghostty ~/.config/ghostty

echo "Done setting up symlinks"
