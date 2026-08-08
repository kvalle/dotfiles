#!/bin/bash
set -euo pipefail

if ! op whoami >/dev/null 2>&1; then
  echo "1Password CLI er ikke autentisert. Logger inn..."
  op signin
  op whoami >/dev/null
fi

echo "Setting up secrets..."

SECRETS_DIR="$HOME/.secrets"
SECRET_FILE="$SECRETS_DIR/digipost-github-secret"

mkdir -p "$SECRETS_DIR"
chmod 700 "$SECRETS_DIR"

echo "Fetching Digipost GitHub secret from 1Password..."
tmp=$(mktemp "$SECRETS_DIR/.digipost-github-secret.XXXXXX")
trap 'rm -f "$tmp"' EXIT
chmod 600 "$tmp"
op read 'op://Private/Digipost GitHub secret/password' --account my.1password.com > "$tmp"
mv -f "$tmp" "$SECRET_FILE"
trap - EXIT

echo "Done setting up secrets"
