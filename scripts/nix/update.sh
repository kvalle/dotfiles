#!/bin/bash

set -uo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"

if ! command -v nix >/dev/null 2>&1; then
  dotfiles_warn "Nix not available, skipping Nix packages"
  exit "$DOTFILES_EXIT_SKIPPED"
fi

if nix flake update --flake "$DOTFILES/nix" && "$SCRIPT_DIR/apply.sh"; then
  dotfiles_success "Nix packages updated."
else
  dotfiles_warn "The Nix update failed; the previous profile generation is still available"
  exit 1
fi
