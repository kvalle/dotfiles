#!/bin/bash
# Applies the custom Zen Browser icon from zen/zen-icon.icns.
# Cask upgrades replace Zen.app and drop the icon, so update.sh runs this too.
# Exits with DOTFILES_EXIT_SKIPPED when Zen is not installed.

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"

ZEN_APP=/Applications/Zen.app
ZEN_ICON="$DOTFILES/zen/zen-icon.icns"

dotfiles_info "Setting the Zen Browser icon..."

if [[ ! -d "$ZEN_APP" ]]; then
  dotfiles_warn "$ZEN_APP not found, skipping"
  exit "$DOTFILES_EXIT_SKIPPED"
fi
command -v fileicon >/dev/null 2>&1 || dotfiles_die "fileicon is not installed (see Brewfile)"
[[ -f "$ZEN_ICON" ]] || dotfiles_die "Icon not found: $ZEN_ICON"
# A cask installed or upgraded under sudo can leave Zen.app owned by root.
[[ -w "$ZEN_APP" ]] || dotfiles_die "$ZEN_APP is not writable (owner: $(stat -f %Su "$ZEN_APP")). Run: sudo chown -R \"\$USER\":admin $ZEN_APP"

fileicon set "$ZEN_APP" "$ZEN_ICON" >/dev/null
# The Dock caches icons; restarting it shows the new one immediately.
killall Dock 2>/dev/null || true
dotfiles_success "Zen icon set."
