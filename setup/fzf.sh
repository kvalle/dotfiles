#!/bin/bash
set -e

echo "Starting configuring fzf"

if test $(which fzf); then
  if [ -f ~/.fzf.zsh ]; then
    echo "fzf already set up"
  else
    echo "setting up fzf"
    $(brew --prefix)/opt/fzf/install
  fi
else
  echo "fzf not installed, please install it first"
fi

echo "Done configuring fzf"
