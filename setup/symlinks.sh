#! /bin/sh
set -e

echo "Starting setting up symlinks"

rm ~/.bashrc || true
ln -s ~/dotfiles/bashrc ~/.bashrc

rm ~/.gitconfig || true
ln -s ~/dotfiles/gitconfig ~/.gitconfig

rm ~/.gitignore || true
ln -s ~/dotfiles/gitignore ~/.gitignore

rm ~/.pythonrc || true
ln -s ~/dotfiles/pythonrc ~/.pythonrc

rm ~/.ghci || true
ln -s ~/dotfiles/ghci ~/.ghci

rm ~/.zprofile || true
ln -s ~/dotfiles/oh-my-zsh-custom/zprofile ~/.zprofile

rm ~/.zshrc || true
ln -s ~/dotfiles/zshrc ~/.zshrc

rm ~/.config/starship.toml || true
mkdir -p ~/.config
ln -s ~/dotfiles/starship.toml ~/.config/starship.toml

rm -rf ~/.config/ghostty || true
mkdir -p ~/.config
ln -s ~/dotfiles/ghostty ~/.config/ghostty

echo "Done setting up symlinks"
