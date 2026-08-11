#!/bin/bash

set -o pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/verify.sh"

verify_header "Tools"

while IFS= read -r line; do
  pkg=$(echo "$line" | sed -n 's/^brew "\([^"]*\)".*/\1/p')
  pkg_short="${pkg##*/}"

  if echo "$line" | grep -q '\[verify cmd:[^]]*\]'; then
    cmd=$(echo "$line" | sed -n 's/.*\[verify cmd:\([^]]*\)\].*/\1/p')
    if command -v "$cmd" >/dev/null 2>&1; then
      verify_pass "$pkg_short ($cmd)"
    else
      verify_fail "$pkg_short ($cmd not on PATH)"
    fi
  elif echo "$line" | grep -q '\[verify\]'; then
    if command -v "$pkg_short" >/dev/null 2>&1; then
      verify_pass "$pkg_short"
    else
      verify_fail "$pkg_short (not on PATH)"
    fi
  fi
done < <(grep '\[verify' "$DOTFILES/Brewfile" | grep -v '^\s*#')

verify_header "Zsh plugins"

if command -v brew >/dev/null 2>&1; then
  BREW_PREFIX=$(brew --prefix)
  while IFS= read -r line; do
    pkg=$(echo "$line" | sed -n 's/^brew "\([^"]*\)".*/\1/p')
    pkg_short="${pkg##*/}"
    plugin_file="$BREW_PREFIX/share/$pkg_short/$pkg_short.zsh"

    if [ -f "$plugin_file" ]; then
      verify_pass "$pkg_short"
    else
      verify_fail "$pkg_short ($plugin_file missing)"
    fi
  done < <(grep '\[verify zsh-plugin\]' "$DOTFILES/Brewfile" | grep -v '^\s*#')
else
  verify_fail "brew (not on PATH)"
fi

verify_finish
