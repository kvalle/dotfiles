#!/bin/bash

set -o pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/verify-output.sh"
ROOT="$DOTFILES"

# Only the colours are checked here. That the theme files parse at all is
# scripts/configs/verify.sh's question, and that bat has them cached is
# scripts/bat/verify.sh's.

verify_header "Terminal themes"

if output=$(ruby "$SCRIPT_DIR/generate-starship.rb" --check 2>&1); then
  verify_pass "Generated Starship configs"
else
  verify_fail "Generated Starship configs"
  [ -z "$output" ] || sed 's/^/      /' <<< "$output"
fi

if grep -R -E -i \
    'Catppuccin Latte|Flexoki|Rose Pine|Tokyo Night|TokyoNight|Monokai Extended Light' \
    "$ROOT"/kitty "$ROOT"/ghostty "$ROOT"/starship "$ROOT"/lazygit \
    "$ROOT"/bat "$ROOT"/btop "$ROOT"/superfile "$ROOT"/tuxedo \
    "$ROOT"/atuin "$ROOT"/tealdeer "$ROOT"/glow "$ROOT"/ai \
    "$ROOT"/zsh >/dev/null 2>&1; then
  verify_fail "No obsolete active theme references"
else
  verify_pass "No obsolete active theme references"
fi

if grep -E -i \
    '#(24273a|cad3f5|b8c0e0|a5adcb|939ab7|8087a2|6e738d|5b6078|494d64|363a4f|ed8796|ee99a0|f5a97f|eed49f|a6da95|8bd5ca|91d7e3|7dc4e4|8aadf4|b7bdf8|c6a0f6|f5bde6|f0c6c6|f4dbd6)' \
    "$ROOT/starship/starship-light.toml" \
    "$ROOT/kitty/light-theme.auto.conf" \
    "$ROOT/kitty/themes/everforest-light-contrast.conf" \
    "$ROOT/ghostty/themes/everforest-light-contrast" \
    "$ROOT/lazygit/themes/everforest-light-contrast.yml" \
    "$ROOT/bat/themes/everforest-light-contrast.tmTheme" \
    "$ROOT/btop/themes/everforest-light-contrast.theme" \
    "$ROOT/superfile/theme/everforest-light-contrast.toml" \
    "$ROOT/tuxedo/themes/everforest-light-contrast.toml" >/dev/null 2>&1; then
  verify_fail "No Macchiato colors in light-only configs"
else
  verify_pass "No Macchiato colors in light-only configs"
fi

verify_finish
