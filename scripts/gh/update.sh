#!/bin/bash

set -uo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"

MANIFEST="$DOTFILES/gh/extensions.txt"
status=0

if ! command -v gh >/dev/null 2>&1; then
  dotfiles_warn "gh is not installed, skipping GitHub CLI extensions"
  exit "$DOTFILES_EXIT_SKIPPED"
fi

while IFS= read -r extension; do
  [[ -n "$extension" && "$extension" != \#* ]] || continue
  if ! gh extension upgrade "$extension"; then
    status=1
  fi
done < "$MANIFEST"

exit "$status"
