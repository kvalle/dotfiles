#!/bin/bash

set -o pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/verify-output.sh"

verify_header "Homebrew"

# `brew bundle check` asks Homebrew whether everything the Brewfile declares is
# installed; --verbose names what is missing. --no-upgrade keeps the question at
# "installed" rather than "up to date": an app that updates itself leaves brew's
# recorded version behind, and would otherwise be reported every single run.
if ! command -v brew >/dev/null 2>&1; then
  verify_fail "brew (not on PATH)"
elif output=$(brew bundle check --file="$DOTFILES/Brewfile" --verbose --no-upgrade 2>&1); then
  verify_pass "every package in the Brewfile is installed"
else
  # brew bullets each unmet dependency; the rest of the output is its own
  # progress and warnings. Fall back to the whole thing if nothing matches.
  missing=$(printf '%s\n' "$output" | sed -n '/needs to be installed/s/^[^A-Za-z]*//p')
  if [ -n "$missing" ]; then
    while IFS= read -r line; do
      verify_fail "$line"
    done <<< "$missing"
  else
    verify_fail "the Brewfile is not fully installed"
    if [ -n "$output" ]; then
      printf '%s\n' "$output" | sed 's/^/      /'
    fi
  fi
fi

verify_finish
