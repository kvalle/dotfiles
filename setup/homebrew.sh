#!/bin/bash
set -e

echo "Starting installing and configuring Homebrew"

if test ! $(which brew); then
  echo "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "Updating Homebrew"
brew update

echo "Installing apps"
brew bundle

echo "Done installing and configuring Homebrew"
