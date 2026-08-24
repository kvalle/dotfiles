#!/bin/bash

# Hover — vis at det kan trykkes (samme som wifi/bluetooth) — theme-aware
if [[ "${SENDER:-}" == "mouse.entered" ]]; then
  if [[ $(defaults read -g AppleInterfaceStyle 2>/dev/null) == Dark ]]; then
    sketchybar --set "$NAME" background.color=0x44ffffff
  else
    sketchybar --set "$NAME" background.color=0x33000000
  fi
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

# Color grading — theme-aware (same palette as appearance.sh)
if [[ $(defaults read -g AppleInterfaceStyle 2>/dev/null) == Dark ]]; then
  FG=0xffcad3f5
  RED=0xffed8796
  MID=0xfff5a97f
else
  FG=0xff3d413d
  RED=0xffd20f39
  MID=0xfffe640b
fi

if (( percentage <= 20 )); then
  icon_color="$RED"
  label_color="$RED"
elif (( percentage == 100 )); then
  icon_color="$FG"
  label_color="$FG"
elif [[ "$charging" == true ]]; then
  icon_color="$FG"
  label_color="$FG"
else
  icon_color="$MID"
  label_color="$MID"
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
  sketchybar --set "$NAME" drawing=on icon="$icon" label="${percentage}%" label.drawing=on icon.padding_left=8 icon.padding_right=4 icon.color="$icon_color" label.color="$label_color"
else
  # icon-only: symmetric padding to center icon in hover box (like wifi/bluetooth)
  sketchybar --set "$NAME" drawing=on icon="$icon" label="${percentage}%" label.drawing=off icon.padding_left=8 icon.padding_right=8 icon.color="$icon_color" label.color="$label_color"
fi
