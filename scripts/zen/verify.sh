#!/bin/bash

set -o pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/verify-output.sh"

ZEN_APP=/Applications/Zen.app

verify_header "Zen Browser icon"

# fileicon can only tell whether a custom icon is set, not which one.
if [[ ! -d "$ZEN_APP" ]]; then
  verify_warn "Zen icon (Zen is not installed)"
elif ! command -v fileicon >/dev/null 2>&1; then
  verify_fail "Zen icon (fileicon is not installed, see Brewfile)"
elif fileicon test "$ZEN_APP" >/dev/null 2>&1; then
  verify_pass "Custom icon set on $ZEN_APP"
else
  verify_fail "No custom icon on $ZEN_APP (run: scripts/zen/setup.sh)"
fi

verify_finish
