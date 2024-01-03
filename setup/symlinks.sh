#! /bin/sh
set -e

rm ~/.bashrc
ln -s ~/dotfiles/bashrc ~/.bashrc

rm ~/.gitconfig
ln -s ~/dotfiles/gitconfig ~/.gitconfig

rm ~/.gitignore
ln -s ~/dotfiles/gitignore ~/.gitignore

rm ~/.pythonrc
ln -s ~/dotfiles/pythonrc ~/.pythonrc

rm ~/.ghci
ln -s ~/dotfiles/ghci ~/.ghci

echo "Done setting up symlinks"
