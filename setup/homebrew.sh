#!/bin/bash
set -e

PRIVILEGES_CLI=$(which PrivilegesCLI 2>/dev/null) || \
  PRIVILEGES_CLI="/Applications/Privileges.app/Contents/MacOS/PrivilegesCLI"

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
$PRIVILEGES_CLI --add --reason "Homebrew bundle install"
brew bundle
$PRIVILEGES_CLI --remove

echo "Done installing and configuring Homebrew"
