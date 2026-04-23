#! /bin/sh
set -e

echo "Setting up secrets..."

mkdir -p ~/.secrets
chmod 700 ~/.secrets

echo "Fetching Digipost GitHub secret from 1Password..."
op read 'op://Private/Digipost GitHub secret/password' --account my.1password.com > ~/.secrets/digipost-github-secret

echo "Done setting up secrets"
