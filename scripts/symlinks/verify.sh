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
done < <(conf_entries)

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

if ! git_history_available; then
  verify_warn "Kan ikke se etter foreldreløse symlinker uten git-historikken"
else
  orphans=$(orphan_symlinks)
  if [ -z "$orphans" ]; then
    verify_pass "Ingen foreldreløse symlinker"
  else
    while IFS=$'\t' read -r dest target; do
      verify_warn "$dest -> $target (ikke i symlinks.conf, fjernes med scripts/symlinks/setup.sh --prune)"
    done <<< "$orphans"
  fi
fi

verify_finish
