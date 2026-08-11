#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/common.sh"

if ! op whoami >/dev/null 2>&1; then
  echo "1Password CLI is not authenticated. Signing in..."
  op signin
  op whoami >/dev/null
fi

echo "Setting up secrets..."

mkdir -p "$SECRETS_DIR"
chmod 700 "$SECRETS_DIR"

# Each secret is written to a mode 600 temp file and moved into place, so a
# failed fetch never leaves a half-written file where the real one belongs. The
# temp path is a script-level variable rather than a local: the EXIT trap runs
# after the loop's scope is gone, and would otherwise have nothing to clean up.
tmp=""
cleanup() {
  if [[ -n "$tmp" ]]; then
    rm -f "$tmp"
  fi
}
trap cleanup EXIT

while read -r name ref; do
  [[ "$name" != */* ]] || dotfiles_die "Target must be a file name without a directory: $name"
  [[ "$ref" == op://* ]] || dotfiles_die "Invalid op reference for $name: $ref"

  echo "Fetching $name from 1Password..."
  tmp=$(mktemp "$SECRETS_DIR/.$name.XXXXXX")
  chmod 600 "$tmp"
  op read "$ref" --account "$OP_ACCOUNT" > "$tmp"
  mv -f "$tmp" "$SECRETS_DIR/$name"
  tmp=""
done < <(secret_entries)

echo "Done setting up secrets"
