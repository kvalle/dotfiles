#!/bin/bash

# toggle-label.sh — click_script for cpu/mem/battery
# Toggles label.drawing individually per item and persists state across restarts.
# Defaults: battery=on (show %), cpu/mem=off (icon only)

set -u

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/sketchybar"
mkdir -p "$CACHE_DIR"
SHOW_FILE="$CACHE_DIR/$NAME.show"

current=""
if [[ -f "$SHOW_FILE" ]]; then
  current=$(cat "$SHOW_FILE" 2>/dev/null || echo "")
fi

if [[ -z "$current" ]]; then
  case "$NAME" in
    battery) current="on" ;;
    *) current="off" ;;
  esac
fi

if [[ "$current" == "on" ]]; then
  echo "off" > "$SHOW_FILE"
  sketchybar --set "$NAME" label.drawing=off icon.padding_left=8 icon.padding_right=8
else
  echo "on" > "$SHOW_FILE"
  sketchybar --set "$NAME" label.drawing=on icon.padding_left=8 icon.padding_right=4
fi
