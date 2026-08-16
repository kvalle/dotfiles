#!/bin/bash

set -o pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/verify-output.sh"

MANIFEST="$DOTFILES/gh/extensions.txt"

verify_header "GitHub CLI extensions"

if ! command -v gh >/dev/null 2>&1; then
  verify_fail "gh (not on PATH)"
elif ! installed=$(gh extension list 2>&1); then
  verify_fail "could not list installed extensions"
  printf '%s\n' "$installed" | sed 's/^/      /'
else
  installed=$(printf '%s\n' "$installed" | cut -f2 | LC_ALL=C sort)
  declared=$(grep -Ev '^[[:space:]]*(#|$)' "$MANIFEST" | LC_ALL=C sort)

  while IFS= read -r extension; do
    [[ -n "$extension" ]] || continue
    if grep -Fxq "$extension" <<< "$installed"; then
      verify_pass "$extension"
    else
      verify_fail "$extension (not installed)"
    fi
  done <<< "$declared"

  while IFS= read -r extension; do
    [[ -n "$extension" ]] || continue
    if ! grep -Fxq "$extension" <<< "$declared"; then
      verify_fail "$extension (not declared; remove with: gh extension remove ${extension##*/})"
    fi
  done <<< "$installed"
fi

verify_finish
