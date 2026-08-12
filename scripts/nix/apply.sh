#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"

FLAKE="$DOTFILES/nix"
PROFILE="$DOTFILES_NIX_PROFILE"

if ! command -v nix >/dev/null 2>&1; then
  echo "Nix is not installed or not on PATH." >&2
  exit 1
fi

if [[ "$(uname -m)" != "arm64" ]]; then
  echo "The Nix configuration currently supports Apple Silicon only." >&2
  exit 1
fi

mkdir -p "$(dirname "$PROFILE")"

# Create the lock file on the first run, but do not update an existing lock.
nix flake lock "$FLAKE"

if [[ -e "$PROFILE" || -L "$PROFILE" ]]; then
  nix profile upgrade --all \
    --profile "$PROFILE"
else
  nix profile add \
    --profile "$PROFILE" \
    "path:$FLAKE"
fi

echo "Active profile: $PROFILE"
echo "Rollback: nix profile rollback --profile $PROFILE"
