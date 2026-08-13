#!/bin/bash

set -o pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/verify-output.sh"

verify_header "Bat theme cache"

if ! command -v bat >/dev/null 2>&1; then
  verify_warn "bat themes (bat is not installed)"
else
  bat_themes=$(bat --list-themes 2>/dev/null)
  for theme in 'everforest-light-contrast' 'Catppuccin Macchiato'; do
    if grep -qx "$theme" <<< "$bat_themes"; then
      verify_pass "$theme"
    else
      verify_fail "$theme (run: bat cache --build)"
    fi
  done
fi

verify_finish
