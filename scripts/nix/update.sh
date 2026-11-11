#!/bin/bash

set -uo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"

if ! command -v nix >/dev/null 2>&1; then
  dotfiles_warn "Nix not available, skipping Nix packages"
  exit "$DOTFILES_EXIT_SKIPPED"
fi

# Anonymous GitHub API calls are limited to 60 per hour per IP, which a shared
# IP can exhaust. Lend Nix the gh login token for this run only; gh is optional
# and without it the update falls back to anonymous requests.
flake_update() {
  local token
  if command -v gh >/dev/null 2>&1 && token=$(gh auth token 2>/dev/null) && [[ -n "$token" ]]; then
    NIX_CONFIG="${NIX_CONFIG:+$NIX_CONFIG
}access-tokens = github.com=$token" nix flake update --flake "$DOTFILES/nix"
  else
    nix flake update --flake "$DOTFILES/nix"
  fi
}

if flake_update && "$SCRIPT_DIR/apply.sh"; then
  dotfiles_success "Nix packages updated."
else
  dotfiles_warn "The Nix update failed; the previous profile generation is still available"
  exit 1
fi
