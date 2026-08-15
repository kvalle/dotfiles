#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/privileges.sh"

dotfiles_info "Installing and configuring Homebrew..."

if ! command -v brew >/dev/null 2>&1; then
  dotfiles_info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

dotfiles_info "Updating Homebrew..."
brew update

dotfiles_info "Trusting third-party taps from the Brewfile..."
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

dotfiles_info "Installing apps from the Brewfile..."
dotfiles_privileges_begin "Homebrew bundle install"
if brew bundle --file="$DOTFILES/Brewfile"; then
  bundle_status=0
else
  bundle_status=$?
  dotfiles_warn "Some Brewfile dependencies failed to install"
fi
dotfiles_privileges_cleanup || dotfiles_die "Temporary admin privileges were not revoked."

if (( bundle_status != 0 )); then
  exit "$bundle_status"
fi

dotfiles_success "Homebrew configured."
