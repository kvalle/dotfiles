#!/bin/bash

SECRETS_DIR="$HOME/.secrets"

# Every entry in secrets.conf is read from the same 1Password account. That is a
# property of the sign-in rather than of the individual secret, so it lives here
# instead of being repeated on every line of the config.
OP_ACCOUNT="my.1password.com"

# The lines of secrets.conf that declare a secret. Callers read them with
# `read -r name ref`, which leaves any spaces inside the op reference intact.
secret_entries() {
  grep -v '^\s*#' "$DOTFILES/secrets.conf" | grep -v '^\s*$'
}

# The file names secrets.conf declares, one per line.
declared_secrets() {
  local name ref
  while read -r name ref; do
    printf '%s\n' "$name"
  done < <(secret_entries)
}
