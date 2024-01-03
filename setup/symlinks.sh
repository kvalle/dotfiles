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

echo "Done setting up symlinks"
