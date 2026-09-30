#!/bin/bash

set -o pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/verify-output.sh"

verify_header "Nix"

NIX_PROFILE="$DOTFILES_NIX_PROFILE"
NIX_COMMANDS="$NIX_PROFILE/share/dotfiles/nix-commands"
if ! command -v nix >/dev/null 2>&1; then
  verify_fail "nix (not on PATH)"
elif [ ! -f "$NIX_COMMANDS" ]; then
  verify_fail "dotfiles profile (command manifest missing)"
else
  while IFS= read -r cmd; do
    [ -n "$cmd" ] || continue
    expected="$NIX_PROFILE/bin/$cmd"
    if [ ! -x "$expected" ]; then
      verify_fail "$cmd (missing from the Nix profile)"
    elif [ "$(command -v "$cmd")" != "$expected" ]; then
      verify_fail "$cmd (the Nix profile is not first on PATH)"
    else
      verify_pass "$cmd"
    fi
  done < "$NIX_COMMANDS"
fi

NIX_APPS_DIR="$HOME/Applications/Nix Apps"
for app in "$NIX_PROFILE/Applications"/*.app; do
  [ -e "$app" ] || continue
  name=$(basename "$app")
  marker="$NIX_APPS_DIR/.$name.store-path"
  if [ ! -d "$NIX_APPS_DIR/$name" ] || [ ! -f "$marker" ]; then
    verify_fail "$name (not copied to $NIX_APPS_DIR, run scripts/nix/sync-apps.sh)"
  elif [ "$(cat "$marker")" != "$(readlink -f "$app")" ]; then
    verify_fail "$name (stale copy in $NIX_APPS_DIR, run scripts/nix/sync-apps.sh)"
  else
    verify_pass "$name (in $NIX_APPS_DIR)"
  fi
done

verify_finish
