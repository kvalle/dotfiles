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
    verify_fail "zsh/$mod.sh (mangler)"
  fi
done

func_count=$(find "$DOTFILES/zsh/functions" -name "*.sh" 2>/dev/null | wc -l | tr -d ' ')
if [ "$func_count" -gt 0 ]; then
  verify_pass "zsh/functions/ ($func_count funksjoner)"
else
  verify_fail "zsh/functions/ (tom eller mangler)"
fi

verify_finish
