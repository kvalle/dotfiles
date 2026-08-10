#!/bin/bash

set -u

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"

# npx kommer fra fnm; se dotfiles_use_node i scripts/lib/common.sh.
dotfiles_use_node || dotfiles_warn "fnm ikke tilgjengelig"

if ! command -v npx >/dev/null 2>&1; then
  dotfiles_warn "npx ikke tilgjengelig, hopper over agent skills"
  exit 0
fi

update_args=(--yes skills update -g)
[[ -t 0 ]] || update_args+=(-y)

if NPM_CONFIG_CACHE="${TMPDIR:-/tmp}/npm-cache" npx "${update_args[@]}"; then
  "$SCRIPT_DIR/manifest.sh" --write || \
    dotfiles_warn "Kunne ikke oppdatere skills-manifestet"
else
  dotfiles_warn "Kunne ikke oppdatere agent skills"
  exit 1
fi
