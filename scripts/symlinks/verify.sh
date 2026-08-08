#!/bin/bash

set -o pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/verify.sh"
source "$SCRIPT_DIR/common.sh"

verify_header "Symlinks"

while read -r type src dest; do
  src="$DOTFILES/$src"
  if ! dest=$(expand_destination "$dest"); then
    verify_fail "$dest (ugyldig relativ målsti)"
    continue
  fi

  if [ ! -e "$dest" ] && [ ! -L "$dest" ]; then
    verify_fail "$dest (mangler)"
  elif [ ! -L "$dest" ]; then
    verify_fail "$dest (eksisterer men er ikke en symlink)"
  else
    actual=$(readlink "$dest")
    if [ "$actual" != "$src" ]; then
      verify_fail "$dest -> $actual (forventet $src)"
    else
      verify_pass "$dest"
    fi
  fi
done < <(grep -v '^\s*#' "$DOTFILES/symlinks.conf" | grep -v '^\s*$')

ZEN_PROFILE=$(find "$HOME/Library/Application Support/zen/Profiles" \
  -maxdepth 1 -name "*.Default (release)" -type d 2>/dev/null | head -1)
if [ -n "$ZEN_PROFILE" ]; then
  zen_dest="$ZEN_PROFILE/user.js"
  zen_src="$DOTFILES/zen/user.js"
  if [ ! -L "$zen_dest" ]; then
    verify_fail "$zen_dest (mangler eller ikke symlink)"
  else
    actual=$(readlink "$zen_dest")
    if [ "$actual" != "$zen_src" ]; then
      verify_fail "$zen_dest -> $actual (forventet $zen_src)"
    else
      verify_pass "$zen_dest"
    fi
  fi
else
  verify_warn "Zen Browser: profil ikke funnet, hopper over"
fi

verify_finish
