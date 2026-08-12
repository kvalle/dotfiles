#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/verify.sh"

verify_header "Zsh modules"

zsh_modules=(options completions environment aliases lazy-loaders tools plugins)
for mod in "${zsh_modules[@]}"; do
  if [ -f "$DOTFILES/zsh/$mod.sh" ]; then
    verify_pass "zsh/$mod.sh"
  else
    verify_fail "zsh/$mod.sh (missing)"
  fi
done

func_count=$(find "$DOTFILES/zsh/functions" -name "*.sh" 2>/dev/null | wc -l | tr -d ' ')
if [ "$func_count" -gt 0 ]; then
  verify_pass "zsh/functions/ ($func_count functions)"
else
  verify_fail "zsh/functions/ (empty or missing)"
fi

verify_header "Zsh plugins"

# Check the paths zsh/plugins.sh actually sources, so this cannot drift from what
# zsh loads.
while IFS= read -r plugin_file; do
  if [ -f "$plugin_file" ]; then
    verify_pass "${plugin_file##*/}"
  else
    verify_fail "${plugin_file##*/} ($plugin_file missing)"
  fi
done < <(sed -n 's/^source \(.*\.zsh\)$/\1/p' "$DOTFILES/zsh/plugins.sh")

verify_finish
