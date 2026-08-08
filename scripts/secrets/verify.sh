#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/verify.sh"

verify_header "Secrets"

if [ -d "$HOME/.secrets" ]; then
  mode=$(stat -f "%Lp" "$HOME/.secrets" 2>/dev/null)
  if [ "$mode" = "700" ]; then
    verify_pass "~/.secrets/ (mode 700)"
  else
    verify_fail "~/.secrets/ (mode $mode, forventet 700)"
  fi
else
  verify_fail "~/.secrets/ (mangler)"
fi

if [ -f "$HOME/.secrets/digipost-github-secret" ]; then
  mode=$(stat -f "%Lp" "$HOME/.secrets/digipost-github-secret" 2>/dev/null)
  if [ "$mode" = "600" ]; then
    verify_pass "~/.secrets/digipost-github-secret (mode 600)"
  else
    verify_fail "~/.secrets/digipost-github-secret (mode $mode, forventet 600)"
  fi
else
  verify_fail "~/.secrets/digipost-github-secret (mangler)"
fi

verify_finish
