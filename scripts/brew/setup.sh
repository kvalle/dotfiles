#!/bin/bash
set -e

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/privileges.sh"

echo "Starting installing and configuring Homebrew"

if test ! $(which brew); then
  echo "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

echo "Updating Homebrew"
brew update

echo "Trusting third-party taps from Brewfile"
grep '^tap ' "$DOTFILES/Brewfile" | sed 's/tap "//;s/".*//' | while read -r t; do
  brew tap "$t" 2>/dev/null || true
  brew trust "$t"
done

echo "Installing apps"
dotfiles_privileges_begin "Homebrew bundle install"
brew bundle --file="$DOTFILES/Brewfile" || echo "Warning: some Brewfile dependencies failed to install"
dotfiles_privileges_cleanup || dotfiles_die "Midlertidige adminrettigheter ble ikke fjernet."

echo "Done installing and configuring Homebrew"
