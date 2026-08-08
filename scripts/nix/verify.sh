#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/verify.sh"

verify_header "Nix"

NIX_PROFILE="$HOME/.local/state/nix/profiles/dotfiles"
NIX_COMMANDS="$NIX_PROFILE/share/dotfiles/nix-commands"
if ! command -v nix >/dev/null 2>&1; then
  verify_fail "nix (ikke i PATH)"
elif [ ! -f "$NIX_COMMANDS" ]; then
  verify_fail "dotfiles-profil (kommandomanifest mangler)"
else
  while IFS= read -r cmd; do
    [ -n "$cmd" ] || continue
    expected="$NIX_PROFILE/bin/$cmd"
    if [ ! -x "$expected" ]; then
      verify_fail "$cmd (mangler i Nix-profilen)"
    elif [ "$(command -v "$cmd")" != "$expected" ]; then
      verify_fail "$cmd (Nix-profilen er ikke først i PATH)"
    else
      verify_pass "$cmd"
    fi
  done < "$NIX_COMMANDS"
fi

verify_finish
