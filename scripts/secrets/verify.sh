#!/bin/bash

set -o pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/verify-output.sh"
source "$SCRIPT_DIR/common.sh"

verify_header "Secrets"

verify_mode() {
  local path=$1 expected=$2 mode
  mode=$(stat -f "%Lp" "$path" 2>/dev/null)
  if [ "$mode" = "$expected" ]; then
    verify_pass "$path (mode $expected)"
  else
    verify_fail "$path (mode $mode, expected $expected)"
  fi
}

if [ -d "$SECRETS_DIR" ]; then
  verify_mode "$SECRETS_DIR" 700
else
  verify_fail "$SECRETS_DIR (missing)"
fi

while read -r name ref; do
  if [ -f "$SECRETS_DIR/$name" ]; then
    verify_mode "$SECRETS_DIR/$name" 600
  else
    verify_fail "$SECRETS_DIR/$name (missing)"
  fi
done < <(secret_entries)

# Files from lines removed from secrets.conf are left behind, and an interrupted
# setup can leave a temp file holding a real secret. Both are worth knowing
# about, but neither is a fault in the setup as it is declared.
declared=$(declared_secrets)
while IFS= read -r path; do
  printf '%s\n' "$declared" | grep -Fxq -- "${path##*/}" && continue
  verify_warn "$path is not declared in secrets.conf"
done < <(find "$SECRETS_DIR" -mindepth 1 -maxdepth 1 2>/dev/null)

verify_finish
