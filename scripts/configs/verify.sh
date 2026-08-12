#!/bin/bash

set -o pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/verify-output.sh"
ROOT="$DOTFILES"

# Grouped in one domain because none of these tools needs setup or update of its
# own — their config is a symlinked file and nothing more. A tool that gains a
# setup step earns its own domain under scripts/ and takes its check along.

verify_header "Tool configs"

check() {
  local description=$1
  shift

  if "$@" >/dev/null 2>&1; then
    verify_pass "$description"
  else
    verify_fail "$description"
  fi
}

check "Git config" git config --file "$ROOT/git/config" --list

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
    "$ROOT/tealdeer/config.toml" \
    "$ROOT/cplt/config.toml" \
    "$ROOT/tuna/config.toml"
  check "YAML configs" yq -oy -p=yaml '.' \
    "$ROOT/eza/theme.yml" \
    "$ROOT/lazygit/config.yml" \
    "$ROOT/lazygit/themes/everforest-light-contrast.yml" \
    "$ROOT/glow/glow.yml"
else
  verify_warn "TOML and YAML configs (yq is not installed)"
fi

if command -v jq >/dev/null 2>&1; then
  check "JSON configs" jq empty \
    "$ROOT/ai/claude/settings.json" \
    "$ROOT/ai/opencode/themes/everforest-macchiato.json"
else
  verify_warn "JSON configs (jq is not installed)"
fi

if command -v lazygit >/dev/null 2>&1; then
  check "LazyGit config" env \
    LG_CONFIG_FILE="$ROOT/lazygit/config.yml" lazygit --config
  check "LazyGit config with light theme" env \
    LG_CONFIG_FILE="$ROOT/lazygit/config.yml,$ROOT/lazygit/themes/everforest-light-contrast.yml" \
    lazygit --config
else
  verify_warn "LazyGit configs (lazygit is not installed)"
fi

if command -v eza >/dev/null 2>&1; then
  check "eza config" env EZA_CONFIG_DIR="$ROOT/eza" eza --color=always "$ROOT"
else
  verify_warn "eza config (eza is not installed)"
fi

if command -v opencode >/dev/null 2>&1; then
  check "OpenCode config" env OPENCODE_CONFIG_DIR="$ROOT/ai/opencode" \
    opencode debug config --pure
else
  verify_warn "OpenCode config (opencode is not installed)"
fi

# Ghostty is a cask, so its CLI lives inside the app bundle rather than on PATH.
ghostty_cli=$(command -v ghostty 2>/dev/null) || \
  ghostty_cli="/Applications/Ghostty.app/Contents/MacOS/ghostty"

if [ ! -x "$ghostty_cli" ]; then
  verify_warn "Ghostty config (ghostty is not installed)"
elif output=$("$ghostty_cli" +validate-config --config-file="$ROOT/ghostty/config" 2>&1); then
  verify_pass "Ghostty config"
else
  verify_fail "Ghostty config"
  [ -z "$output" ] || sed 's/^/      /' <<< "$output"
fi

verify_finish
