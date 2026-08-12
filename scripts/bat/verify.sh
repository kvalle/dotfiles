#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/verify-output.sh"

verify_header "Bat theme cache"

bat_themes=$(bat --list-themes 2>/dev/null)
for theme in 'everforest-light-contrast' 'Catppuccin Macchiato'; do
  if grep -qx "$theme" <<< "$bat_themes"; then
    verify_pass "$theme"
  else
    verify_fail "$theme (run: bat cache --build)"
  fi
done

verify_finish
