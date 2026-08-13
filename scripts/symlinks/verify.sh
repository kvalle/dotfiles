#!/bin/bash

set -o pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/verify-output.sh"
source "$SCRIPT_DIR/common.sh"

verify_header "Symlinks"

while read -r type src dest; do
  src="$DOTFILES/$src"
  if ! dest=$(expand_destination "$dest"); then
    verify_fail "$dest (invalid relative destination path)"
    continue
  fi

  if [ ! -e "$dest" ] && [ ! -L "$dest" ]; then
    verify_fail "$dest (missing)"
  elif [ ! -L "$dest" ]; then
    verify_fail "$dest (exists but is not a symlink)"
  else
    actual=$(readlink "$dest")
    if [ "$actual" != "$src" ]; then
      verify_fail "$dest -> $actual (expected $src)"
    else
      verify_pass "$dest"
    fi
  fi
done < <(conf_entries)

if ZEN_PROFILE=$(zen_profile); then
  zen_dest="$ZEN_PROFILE/user.js"
  zen_src="$DOTFILES/zen/user.js"
  if [ ! -L "$zen_dest" ]; then
    verify_fail "$zen_dest (missing or not a symlink)"
  else
    actual=$(readlink "$zen_dest")
    if [ "$actual" != "$zen_src" ]; then
      verify_fail "$zen_dest -> $actual (expected $zen_src)"
    else
      verify_pass "$zen_dest"
    fi
  fi
else
  verify_warn "Zen Browser: profile not found, skipping"
fi

if ! git_history_available; then
  verify_warn "Cannot look for orphaned symlinks without the git history"
else
  orphans=$(orphan_symlinks)
  if [ -z "$orphans" ]; then
    verify_pass "No orphaned symlinks"
  else
    while IFS=$'\t' read -r dest target; do
      verify_warn "$dest -> $target (not in symlinks.conf, remove with scripts/symlinks/setup.sh --prune)"
    done <<< "$orphans"
  fi
fi

verify_finish
