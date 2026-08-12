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
# Read via process substitution, not a pipe: a piped while loop runs in a
# subshell, so a failure inside it would abort the whole script under `set -e`
# and leave the taps that follow untouched. Collect failures and carry on —
# `brew bundle` below reports any package that could not be installed anyway.
_failed_taps=()
while read -r t; do
  if ! brew tap "$t" 2>/dev/null || ! brew trust --tap "$t"; then
    _failed_taps+=("$t")
  fi
done < <(grep '^tap ' "$DOTFILES/Brewfile" | sed 's/tap "//;s/".*//')

if [[ ${#_failed_taps[@]} -gt 0 ]]; then
  dotfiles_warn "Could not tap/trust: ${_failed_taps[*]}"
fi

echo "Installing apps"
dotfiles_privileges_begin "Homebrew bundle install"
brew bundle --file="$DOTFILES/Brewfile" || echo "Warning: some Brewfile dependencies failed to install"
dotfiles_privileges_cleanup || dotfiles_die "Temporary admin privileges were not revoked."

echo "Done installing and configuring Homebrew"
