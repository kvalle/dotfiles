#!/bin/bash

set -u

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"

if ! command -v npx >/dev/null 2>&1; then
  dotfiles_warn "npx ikke tilgjengelig, hopper over agent skills"
  exit 0
fi

if NPM_CONFIG_CACHE="${TMPDIR:-/tmp}/npm-cache" npx --yes skills update -g -y; then
  "$SCRIPT_DIR/manifest.sh" --write || \
    dotfiles_warn "Kunne ikke oppdatere skills-manifestet"
else
  dotfiles_warn "Kunne ikke oppdatere agent skills"
  exit 1
fi
