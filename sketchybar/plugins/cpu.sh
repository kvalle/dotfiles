#!/bin/bash

# CPU plugin — simple percentage via ps, averaged over cores.

set -u

# Hover — vis at det kan trykkes (samme som wifi/bluetooth)
if [[ "${SENDER:-}" == "mouse.entered" ]]; then
  sketchybar --set "$NAME" background.color=0x44ffffff
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
  sketchybar --set "$NAME" drawing=on icon="$icon" label="${usage}%" label.drawing=on icon.padding_left=8 icon.padding_right=4
else
  # icon-only: symmetric padding to center icon in hover box (like wifi/bluetooth)
  sketchybar --set "$NAME" drawing=on icon="$icon" label="${usage}%" label.drawing=off icon.padding_left=8 icon.padding_right=8
fi
