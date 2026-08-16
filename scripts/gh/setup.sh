#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"

MANIFEST="$DOTFILES/gh/extensions.txt"

dotfiles_info "Installing GitHub CLI extensions..."

if ! command -v gh >/dev/null 2>&1; then
  dotfiles_die "gh is not installed or not on PATH."
fi

while IFS= read -r extension; do
  [[ -n "$extension" && "$extension" != \#* ]] || continue
  name=${extension##*/}
  if gh extension list | cut -f2 | grep -Fxq "$extension"; then
    continue
  fi
  GH_FORCE_TTY=0 gh extension install "$extension"
  dotfiles_success "$name installed."
done < "$MANIFEST"
