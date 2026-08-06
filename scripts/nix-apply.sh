#!/bin/bash

set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/dotfiles}"
FLAKE="$DOTFILES/nix"
PROFILE="${NIX_DOTFILES_PROFILE:-$HOME/.local/state/nix/profiles/dotfiles}"

if ! command -v nix >/dev/null 2>&1; then
  echo "Nix er ikke installert eller finnes ikke i PATH." >&2
  exit 1
fi

if [[ "$(uname -m)" != "arm64" ]]; then
  echo "Nix-konfigurasjonen støtter foreløpig bare Apple Silicon." >&2
  exit 1
fi

mkdir -p "$(dirname "$PROFILE")"

# Opprett låsefilen første gang, men ikke oppdater en eksisterende lås.
nix flake lock "$FLAKE"

if [[ -e "$PROFILE" || -L "$PROFILE" ]]; then
  nix profile upgrade --all \
    --profile "$PROFILE"
else
  nix profile add \
    --profile "$PROFILE" \
    "path:$FLAKE"
fi

echo "Aktiv profil: $PROFILE"
echo "Rollback: nix profile rollback --profile $PROFILE"
