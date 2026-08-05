#!/bin/bash

set -euo pipefail

DEFAULT_PROFILE="${NIX_DEFAULT_PROFILE:-$HOME/.local/state/nix/profiles/profile}"
DOTFILES_PROFILE="${NIX_DOTFILES_PROFILE:-$HOME/.local/state/nix/profiles/dotfiles}"

if ! command -v nix >/dev/null 2>&1; then
  echo "Nix er ikke installert eller finnes ikke i PATH." >&2
  exit 1
fi

echo "Standardprofil"
echo "  $DEFAULT_PROFILE"
if [[ -e "$DEFAULT_PROFILE" || -L "$DEFAULT_PROFILE" ]]; then
  nix profile list --profile "$DEFAULT_PROFILE"
else
  echo "  Ingen standardprofil funnet."
fi

echo ""
echo "Dotfiles-profil"
echo "  $DOTFILES_PROFILE"
if [[ -e "$DOTFILES_PROFILE" || -L "$DOTFILES_PROFILE" ]]; then
  nix profile list --profile "$DOTFILES_PROFILE"
else
  echo "  Ingen dotfiles-profil funnet."
fi

echo ""
echo "Overlappende kommandoer"
if [[ ! -d "$DEFAULT_PROFILE/bin" || ! -d "$DOTFILES_PROFILE/bin" ]]; then
  echo "  Kan ikke sammenligne før begge profilene har en bin-katalog."
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
    echo "    PATH: ${resolved:-ikke funnet}"
  fi
done

if [[ "$overlap_found" == false ]]; then
  echo "  Ingen overlapp funnet."
fi
