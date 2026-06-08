#!/bin/bash
set -e

echo "Starting installing and configuring Homebrew"

if test ! $(which brew); then
  echo "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

echo "Updating Homebrew"
brew update

echo "Trusting third-party taps from Brewfile"
grep '^tap ' Brewfile | sed 's/tap "//;s/".*//' | while read -r t; do
  brew tap "$t" 2>/dev/null || true
  brew trust "$t"
done

echo "Installing apps"
brew bundle

echo "Done installing and configuring Homebrew"
