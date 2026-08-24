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

# Install sketchybar-app-font if missing (needed for front_app icons).
# Source: https://github.com/kvndrsslr/sketchybar-app-font/releases
# Regenerate: curl -fsSL https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v2.0.82/sketchybar-app-font.ttf -o ~/Library/Fonts/sketchybar-app-font.ttf
#            curl -fsSL https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v2.0.82/icon_map.sh -o sketchybar/plugins/icon_map.sh
font="$HOME/Library/Fonts/sketchybar-app-font.ttf"
if [[ ! -f "$font" ]]; then
  version="v2.0.82"
  url="https://github.com/kvndrsslr/sketchybar-app-font/releases/download/${version}/sketchybar-app-font.ttf"
  mkdir -p "$(dirname "$font")"
  if curl -fsSL "$url" -o "$font" 2>/dev/null; then
    dotfiles_success "Installed sketchybar-app-font $version"
  else
    dotfiles_warn "Could not download sketchybar-app-font $version from $url"
  fi
fi

mkdir -p "$HOME/Library/Logs"

launchctl bootout "$domain/$label" >/dev/null 2>&1 || true
# bootstrap can return 5/Input/output error when already loaded or when
# user vs. sudo domain confusion — capture output instead of exiting via set -e
set +e
bootstrap_out=$(launchctl bootstrap "$domain" "$agent" 2>&1)
bootstrap_status=$?
set -e
if (( bootstrap_status == 0 )); then
  dotfiles_success "SketchyBar LaunchAgent loaded."
  exit 0
fi

# If already loaded (race), just kickstart instead
if launchctl print "$domain/$label" >/dev/null 2>&1; then
  launchctl kickstart -k "$domain/$label" >/dev/null 2>&1 || true
  dotfiles_success "SketchyBar LaunchAgent already loaded (kickstarted)."
  exit 0
fi

# Real failure — show hint, keep set -e from aborting before message
dotfiles_warn "launchctl bootstrap failed ($bootstrap_status): $bootstrap_out"
dotfiles_warn "Try for richer diagnostics: sudo launchctl bootstrap $domain $agent"
exit "$bootstrap_status"
