#!/bin/bash

# CPU plugin — simple percentage via ps, averaged over cores.

set -u

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

cores=$(sysctl -n hw.ncpu 2>/dev/null || echo 1)
# Sum %CPU over all processes; ps is instant, no delay like top -l 2
total=$(ps -A -o %cpu= 2>/dev/null | awk '{s+=$1} END {print s+0}')
if [[ -z "$total" ]]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

# Average over cores and clamp 0-100
usage=$(awk -v t="$total" -v c="$cores" 'BEGIN {u=t/c; if(u<0)u=0; if(u>100)u=100; printf "%.0f", u}')

icon=""
if (( usage > 80 )); then
  icon=""
fi

# Color grading — theme-aware (same palette as appearance.sh / battery.sh)
# CPU: <50 FG, 50-80 MID, >80 RED
if [[ $(defaults read -g AppleInterfaceStyle 2>/dev/null) == Dark ]]; then
  FG=0xffcad3f5
  RED=0xffed8796
  MID=0xfff5a97f
else
  FG=0xff3d413d
  RED=0xffd20f39
  MID=0xfffe640b
fi

if (( usage > 80 )); then
  icon_color="$RED"
  label_color="$RED"
elif (( usage >= 50 )); then
  icon_color="$MID"
  label_color="$MID"
else
  icon_color="$FG"
  label_color="$FG"
fi

# Determine label visibility — persisted via toggle-label.sh, default off for cpu
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/sketchybar"
SHOW_FILE="$CACHE_DIR/$NAME.show"
show="off"
if [[ -f "$SHOW_FILE" ]]; then
  show=$(cat "$SHOW_FILE" 2>/dev/null || echo "off")
fi
# Normalize
if [[ "$show" != "on" ]]; then
  show="off"
fi

if [[ "$show" == "on" ]]; then
  sketchybar --set "$NAME" drawing=on icon="$icon" label="${usage}%" label.drawing=on icon.padding_left=8 icon.padding_right=4 icon.color="$icon_color" label.color="$label_color"
else
  # icon-only: symmetric padding to center icon in hover box (like wifi/bluetooth)
  sketchybar --set "$NAME" drawing=on icon="$icon" label="${usage}%" label.drawing=off icon.padding_left=8 icon.padding_right=8 icon.color="$icon_color" label.color="$label_color"
fi
