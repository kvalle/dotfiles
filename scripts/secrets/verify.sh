#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/verify.sh"
source "$SCRIPT_DIR/common.sh"

verify_header "Secrets"

verify_mode() {
  local path=$1 expected=$2 mode
  mode=$(stat -f "%Lp" "$path" 2>/dev/null)
  if [ "$mode" = "$expected" ]; then
    verify_pass "$path (mode $expected)"
  else
    verify_fail "$path (mode $mode, forventet $expected)"
  fi
}

if [ -d "$SECRETS_DIR" ]; then
  verify_mode "$SECRETS_DIR" 700
else
  verify_fail "$SECRETS_DIR (mangler)"
fi

while read -r name ref; do
  if [ -f "$SECRETS_DIR/$name" ]; then
    verify_mode "$SECRETS_DIR/$name" 600
  else
    verify_fail "$SECRETS_DIR/$name (mangler)"
  fi
done < <(secret_entries)

# Filer fra linjer som er fjernet fra secrets.conf blir liggende igjen, og et
# avbrutt setup kan etterlate en temp-fil med et ekte secret. Begge deler er
# verdt å vite om, men ingen av dem er en feil i oppsettet slik det er deklarert.
declared=$(declared_secrets)
while IFS= read -r path; do
  printf '%s\n' "$declared" | grep -Fxq -- "${path##*/}" && continue
  verify_warn "$path står ikke i secrets.conf"
done < <(find "$SECRETS_DIR" -mindepth 1 -maxdepth 1 2>/dev/null)

verify_finish
