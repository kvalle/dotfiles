#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"

label="com.dotfiles.sketchybar"
domain="gui/$UID"
agent="$HOME/Library/LaunchAgents/$label.plist"

if [[ ! -x "$DOTFILES_NIX_PROFILE/bin/sketchybar" ]]; then
  dotfiles_die "SketchyBar is missing from the dotfiles Nix profile."
fi

if [[ ! -f "$agent" ]]; then
  dotfiles_die "LaunchAgent is missing: $agent"
fi

launchctl bootout "$domain/$label" >/dev/null 2>&1 || true
launchctl bootstrap "$domain" "$agent"

dotfiles_success "SketchyBar LaunchAgent loaded."
