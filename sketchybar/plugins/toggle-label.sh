#!/bin/bash

# toggle-label.sh — click_script for cpu/mem/battery
# Toggles label.drawing individually per item and persists state across restarts.
# Defaults: battery=on (show %), cpu/mem=off (icon only)

set -u

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/plugins/helpers.sh"

# Derive default per item (must match metric plugins)
case "$NAME" in
  battery) default="on" ;;
  *) default="off" ;;
esac

current=$(sketchybar_label_visible "$NAME" "$default")

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/sketchybar"
mkdir -p "$CACHE_DIR"
SHOW_FILE="$CACHE_DIR/$NAME.show"

if [[ "$current" == "on" ]]; then
  echo "off" > "$SHOW_FILE"
  sketchybar --set "$NAME" label.drawing=off icon.padding_left=8 icon.padding_right=8
else
  echo "on" > "$SHOW_FILE"
  sketchybar --set "$NAME" label.drawing=on icon.padding_left=8 icon.padding_right=4
fi
