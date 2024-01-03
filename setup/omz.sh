#!/bin/bash
set -e

echo "Starting installing and configuring Oh My Zsh"

if ! [[ -d ~/.oh-my-zsh ]]; then
  echo "Installing oh-my-zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

## check if ~/.zshrc exists
## if it does, remove it
if [[ -f $HOME/.zshrc ]]; then
  rm $HOME/.zshrc
fi

ln -s $HOME/dotfiles/oh-my-zsh-custom/zshrc $HOME/.zshrc

echo "Done installing and configuring Oh My Zsh"
