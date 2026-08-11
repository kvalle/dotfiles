#!/bin/bash

set -euo pipefail

DEFAULT_PROFILE="${NIX_DEFAULT_PROFILE:-$HOME/.local/state/nix/profiles/profile}"
DOTFILES_PROFILE="${NIX_DOTFILES_PROFILE:-$HOME/.local/state/nix/profiles/dotfiles}"

if ! command -v nix >/dev/null 2>&1; then
  echo "Nix is not installed or not on PATH." >&2
  exit 1
fi

echo "Default profile"
echo "  $DEFAULT_PROFILE"
if [[ -e "$DEFAULT_PROFILE" || -L "$DEFAULT_PROFILE" ]]; then
  nix profile list --profile "$DEFAULT_PROFILE"
else
  echo "  No default profile found."
fi

echo ""
echo "Dotfiles profile"
echo "  $DOTFILES_PROFILE"
if [[ -e "$DOTFILES_PROFILE" || -L "$DOTFILES_PROFILE" ]]; then
  nix profile list --profile "$DOTFILES_PROFILE"
else
  echo "  No dotfiles profile found."
fi

echo ""
echo "Overlapping commands"
if [[ ! -d "$DEFAULT_PROFILE/bin" ]]; then
  echo "  No default profile to compare against."
  exit 0
fi

if [[ ! -d "$DOTFILES_PROFILE/bin" ]]; then
  echo "  No dotfiles profile to compare against."
  exit 0
fi

overlap_found=false
for default_command in "$DEFAULT_PROFILE"/bin/*; do
  [[ -e "$default_command" ]] || continue
  command_name="${default_command##*/}"
  if [[ -e "$DOTFILES_PROFILE/bin/$command_name" ]]; then
    overlap_found=true
    resolved=$(command -v "$command_name" 2>/dev/null || true)
    echo "  $command_name"
    echo "    PATH: ${resolved:-not found}"
  fi
done

if [[ "$overlap_found" == false ]]; then
  echo "  No overlap found."
fi
