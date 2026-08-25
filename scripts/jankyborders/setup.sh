#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"

label="com.dotfiles.jankyborders"
domain="gui/$UID"
agent="$HOME/Library/LaunchAgents/$label.plist"

if [[ ! -x "$DOTFILES_NIX_PROFILE/bin/borders" ]]; then
  dotfiles_die "JankyBorders is missing from the dotfiles Nix profile."
fi

if [[ ! -f "$agent" ]]; then
  dotfiles_die "LaunchAgent is missing: $agent"
fi

mkdir -p "$HOME/Library/Logs"

if launchctl print "$domain/$label" >/dev/null 2>&1; then
  launchctl kickstart -k "$domain/$label"
  dotfiles_success "JankyBorders LaunchAgent restarted."
  exit 0
fi

if launchctl bootstrap "$domain" "$agent"; then
  dotfiles_success "JankyBorders LaunchAgent loaded."
  exit 0
fi

dotfiles_warn "launchctl bootstrap failed. Check that the LaunchAgent symlink exists: $agent"
exit 1
