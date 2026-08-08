#!/bin/bash

set -u

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"

if ! command -v nix >/dev/null 2>&1; then
  dotfiles_warn "Nix ikke tilgjengelig, hopper over Nix-pakker"
  exit 0
fi

if nix flake update --flake "$DOTFILES/nix" && "$SCRIPT_DIR/apply.sh"; then
  dotfiles_success "Nix-pakker oppdatert."
else
  dotfiles_warn "Nix-oppdateringen feilet; forrige profilgenerasjon er fortsatt tilgjengelig"
  exit 1
fi
