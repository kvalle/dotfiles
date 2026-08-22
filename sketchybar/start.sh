#!/bin/bash

set -euo pipefail

NIX_PROFILE="$HOME/.local/state/nix/profiles/dotfiles"
export PATH="$NIX_PROFILE/bin:/usr/bin:/bin:/usr/sbin:/sbin"

exec >> "$HOME/Library/Logs/SketchyBar.log" 2>&1
exec "$NIX_PROFILE/bin/sketchybar" --config "$HOME/.config/sketchybar/sketchybarrc"
