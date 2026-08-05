#!/bin/bash

set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/dotfiles}"
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
nix flake lock "$DOTFILES"

if [[ -e "$PROFILE" || -L "$PROFILE" ]]; then
  nix profile upgrade --all \
    --profile "$PROFILE"
else
  nix profile install \
    --profile "$PROFILE" \
    "path:$DOTFILES"
fi

echo "Aktiv profil: $PROFILE"
"$PROFILE/bin/bat" --version
echo "Legg $PROFILE/bin foran Homebrew i PATH for å bruke Nix-pakkene."
echo "Rollback: nix profile rollback --profile $PROFILE"
