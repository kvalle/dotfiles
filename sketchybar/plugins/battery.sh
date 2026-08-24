#!/bin/bash

# Hover — vis at det kan trykkes (samme som wifi/bluetooth)
if [[ "${SENDER:-}" == "mouse.entered" ]]; then
  sketchybar --set "$NAME" background.color=0x44ffffff
  exit 0
elif [[ "${SENDER:-}" == "mouse.exited" ]]; then
  sketchybar --set "$NAME" background.color=0x00000000
  exit 0
fi

percentage=$(pmset -g batt | grep -Eo '[0-9]+%' | tr -d '%' || true)
charging=$(pmset -g batt | grep -q 'AC Power' && printf true || printf false)

if [[ -z "$percentage" ]]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

if [[ "$charging" == true ]]; then
  icon="󰂄"
elif (( percentage <= 20 )); then
  icon="󰁺"
elif (( percentage <= 50 )); then
  icon="󰁾"
elif (( percentage <= 80 )); then
  icon="󰂁"
else
  icon="󰁹"
fi

# Determine label visibility — persisted via toggle-label.sh, default on for battery
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/sketchybar"
SHOW_FILE="$CACHE_DIR/$NAME.show"
show="on"
if [[ -f "$SHOW_FILE" ]]; then
  show=$(cat "$SHOW_FILE" 2>/dev/null || echo "on")
fi
if [[ "$show" != "off" ]]; then
  show="on"
fi

if [[ "$show" == "on" ]]; then
  sketchybar --set "$NAME" drawing=on icon="$icon" label="${percentage}%" label.drawing=on icon.padding_left=8 icon.padding_right=4
else
  # icon-only: symmetric padding to center icon in hover box (like wifi/bluetooth)
  sketchybar --set "$NAME" drawing=on icon="$icon" label="${percentage}%" label.drawing=off icon.padding_left=8 icon.padding_right=8
fi
