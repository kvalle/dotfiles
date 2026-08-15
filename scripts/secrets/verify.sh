#!/bin/bash

set -o pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/verify-output.sh"
source "$SCRIPT_DIR/common.sh"

verify_header "Secrets"

verify_path() {
  local path=$1 expected_type=$2 expected_mode=$3 require_content=$4
  local metadata type owner mode size

  if ! metadata=$(stat -f "%HT|%u|%Lp|%z" "$path" 2>/dev/null); then
    verify_fail "$path (missing)"
    return
  fi
  IFS='|' read -r type owner mode size <<< "$metadata"

  if [ "$type" != "$expected_type" ]; then
    verify_fail "$path (type $type, expected $expected_type)"
    return
  fi

  if [ "$owner" != "$(id -u)" ]; then
    verify_fail "$path (owned by uid $owner, expected $(id -u))"
  elif [ "$mode" != "$expected_mode" ]; then
    verify_fail "$path (mode $mode, expected $expected_mode)"
  elif [ "$require_content" = true ] && [ "$size" -eq 0 ]; then
    verify_fail "$path (empty)"
  else
    verify_pass "$path (type, owner, mode and content OK)"
  fi
}

directory_type=$(stat -f "%HT" "$SECRETS_DIR" 2>/dev/null)
verify_path "$SECRETS_DIR" "Directory" 700 false

while read -r name _; do
  verify_path "$SECRETS_DIR/$name" "Regular File" 600 true
done < <(secret_entries)

# Files from lines removed from secrets.conf are left behind, and an interrupted
# setup can leave a temp file holding a real secret. Both are worth knowing
# about, but neither is a fault in the setup as it is declared.
if [ "$directory_type" = "Directory" ]; then
  declared=$(declared_secrets)
  while IFS= read -r path; do
    printf '%s\n' "$declared" | grep -Fxq -- "${path##*/}" && continue
    verify_warn "$path is not declared in secrets.conf"
  done < <(find "$SECRETS_DIR" -mindepth 1 -maxdepth 1 2>/dev/null)
fi

verify_finish
