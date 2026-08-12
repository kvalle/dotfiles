#!/bin/bash

set -o pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/verify.sh"

verify_header "Homebrew"

# `brew bundle check` asks Homebrew whether everything the Brewfile declares is
# installed; --verbose lists what is missing rather than only an exit status.
if ! command -v brew >/dev/null 2>&1; then
  verify_fail "brew (not on PATH)"
elif output=$(brew bundle check --file="$DOTFILES/Brewfile" --verbose 2>&1); then
  verify_pass "every package in the Brewfile is installed"
else
  verify_fail "the Brewfile is not fully installed"
  printf '%s\n' "$output" | sed 's/^/      /'
fi

verify_finish
