#!/bin/bash

# toggle-label.sh — click_script for cpu/mem/battery/volume
# Toggles label.drawing individually per item and persists state across restarts.
# Defaults: battery/volume=on (show %), cpu/mem=off (icon only)

set -u

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/plugins/helpers.sh"

# Derive default per item (must match metric plugins)
case "$NAME" in
  battery|volume) default="on" ;;
  *) default="off" ;;
esac

current=$(sketchybar_label_visible "$NAME" "$default")

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/sketchybar"
mkdir -p "$CACHE_DIR"
SHOW_FILE="$CACHE_DIR/$NAME.show"

if [[ "$current" == "on" ]]; then
  echo "off" > "$SHOW_FILE"
  # Reset hover highlight — when label hides the item shrinks and the
  # cursor can end up outside the new bounds without a mouse.exited
  # event, leaving background.color stuck highlighted.
  # Smooth width slide (sin 15 ≈ 250ms) keeps label.drawing=on and animates label.width.
  sketchybar --animate sin 15 --set "$NAME" label.width=0 icon.padding_left=8 icon.padding_right=8 background.color=0x00000000 label.drawing=on
else
  echo "on" > "$SHOW_FILE"
  sketchybar --animate sin 15 --set "$NAME" label.width=dynamic label.drawing=on icon.padding_left=8 icon.padding_right=4
fi
