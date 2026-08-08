#!/bin/bash

set -o pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/lib/common.sh"
ROOT="$DOTFILES"
ISSUES=0

pass() {
  printf 'PASS  %s\n' "$1"
}

fail() {
  printf 'FAIL  %s\n' "$1"
  ISSUES=$((ISSUES + 1))
}

skip() {
  printf 'SKIP  %s\n' "$1"
}

check() {
  local description=$1
  shift

  if "$@" >/dev/null 2>&1; then
    pass "$description"
  else
    fail "$description"
  fi
}

check "Zsh syntax" zsh -n \
  "$ROOT/zshrc" "$ROOT/zprofile" "$ROOT"/zsh/*.sh "$ROOT"/zsh/functions/*.sh
check "Generated Starship configs" ruby \
  "$ROOT/scripts/generate-starship-configs.rb" --check

if command -v bat >/dev/null 2>&1; then
  if bat --list-themes | grep -qx 'everforest-light-contrast'; then
    pass "Bat light theme"
  else
    fail "Bat light theme (run: bat cache --build)"
  fi
else
  skip "Bat light theme (bat is not installed)"
fi

if command -v yq >/dev/null 2>&1; then
  check "TOML configs" yq -oy -p=toml '.' \
    "$ROOT/starship/starship.toml" \
    "$ROOT/starship/starship-light.toml" \
    "$ROOT/superfile/config.toml" \
    "$ROOT/superfile/hotkeys.toml" \
    "$ROOT/superfile/theme/everforest-light-contrast.toml" \
    "$ROOT/superfile/theme/catppuccin-macchiato.toml" \
    "$ROOT/atuin/config.toml" \
    "$ROOT/atuin/themes/terminal.toml" \
    "$ROOT/tealdeer/config.toml"
  check "YAML configs" yq -oy -p=yaml '.' \
    "$ROOT/eza/theme.yml" \
    "$ROOT/lazygit/config.yml" \
    "$ROOT/lazygit/themes/everforest-light-contrast.yml" \
    "$ROOT/glow/glow.yml"
else
  skip "TOML and YAML configs (yq is not installed)"
fi

if command -v jq >/dev/null 2>&1; then
  check "JSON configs" jq empty \
    "$ROOT/ai/claude/settings.json" \
    "$ROOT/ai/opencode/themes/everforest-macchiato.json"
else
  skip "JSON configs (jq is not installed)"
fi

check "Git config" git config --file "$ROOT/git/config" --list

if command -v lazygit >/dev/null 2>&1; then
  check "LazyGit dark config" env \
    LG_CONFIG_FILE="$ROOT/lazygit/config.yml" lazygit --config
  check "LazyGit light config" env \
    LG_CONFIG_FILE="$ROOT/lazygit/config.yml,$ROOT/lazygit/themes/everforest-light-contrast.yml" \
    lazygit --config
else
  skip "LazyGit configs (lazygit is not installed)"
fi

if command -v eza >/dev/null 2>&1; then
  check "eza theme" env EZA_CONFIG_DIR="$ROOT/eza" eza --color=always "$ROOT"
else
  skip "eza theme (eza is not installed)"
fi

if command -v opencode >/dev/null 2>&1; then
  check "OpenCode config and theme" env OPENCODE_CONFIG_DIR="$ROOT/ai/opencode" \
    opencode debug config --pure
else
  skip "OpenCode config and theme (opencode is not installed)"
fi

if grep -R -E -i \
    'Catppuccin Latte|Flexoki|Rose Pine|Tokyo Night|TokyoNight|Monokai Extended Light' \
    "$ROOT"/kitty "$ROOT"/ghostty "$ROOT"/starship "$ROOT"/lazygit \
    "$ROOT"/bat "$ROOT"/btop "$ROOT"/superfile "$ROOT"/tuxedo \
    "$ROOT"/atuin "$ROOT"/tealdeer "$ROOT"/glow "$ROOT"/ai \
    "$ROOT"/zsh >/dev/null 2>&1; then
  fail "No obsolete active theme references"
else
  pass "No obsolete active theme references"
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
  fail "No Macchiato colors in light-only configs"
else
  pass "No Macchiato colors in light-only configs"
fi

check "Whitespace errors" git -C "$ROOT" diff HEAD --check

if (( ISSUES > 0 )); then
  printf '\n%d check(s) failed.\n' "$ISSUES"
  exit 1
fi

printf '\nAll available terminal-theme checks passed.\n'
