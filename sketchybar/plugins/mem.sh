#!/bin/bash

# Memory plugin — percentage used, via memory_pressure if available.

set -u

# Hover — vis at det kan trykkes (samme som wifi/bluetooth)
if [[ "${SENDER:-}" == "mouse.entered" ]]; then
  sketchybar --set "$NAME" background.color=0x44ffffff
  exit 0
elif [[ "${SENDER:-}" == "mouse.exited" ]]; then
  sketchybar --set "$NAME" background.color=0x00000000
  exit 0
fi

usage=""

# memory_pressure prints "System-wide memory free percentage: 42%"
if command -v memory_pressure >/dev/null 2>&1; then
  free_pct=$(memory_pressure 2>/dev/null | grep -o "System-wide memory free percentage: [0-9]*%" | grep -o "[0-9]*" || true)
  if [[ -n "$free_pct" ]]; then
    usage=$((100 - free_pct))
  fi
fi

# Fallback: vm_stat + hw.memsize
if [[ -z "$usage" ]]; then
  pagesize=$(sysctl -n hw.pagesize 2>/dev/null || echo 4096)
  memsize=$(sysctl -n hw.memsize 2>/dev/null || echo 0)
  if (( memsize > 0 )); then
    # vm_stat values are in pages; strip dots
    free_pages=$(vm_stat 2>/dev/null | awk '/Pages free/ {print $3}' | tr -d '.' || echo 0)
    inactive_pages=$(vm_stat 2>/dev/null | awk '/Pages inactive/ {print $3}' | tr -d '.' || echo 0)
    # Approximate free as free+inactive (reclaimable)
    free_bytes=$(( (free_pages + inactive_pages) * pagesize ))
    used_bytes=$(( memsize - free_bytes ))
    if (( used_bytes < 0 )); then used_bytes=0; fi
    usage=$(( used_bytes * 100 / memsize ))
  fi
fi

if [[ -z "$usage" ]]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

if (( usage < 0 )); then usage=0; fi
if (( usage > 100 )); then usage=100; fi

icon="󰑭"

# Determine label visibility — persisted via toggle-label.sh, default off for mem
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/sketchybar"
SHOW_FILE="$CACHE_DIR/$NAME.show"
show="off"
if [[ -f "$SHOW_FILE" ]]; then
  show=$(cat "$SHOW_FILE" 2>/dev/null || echo "off")
fi
if [[ "$show" != "on" ]]; then
  show="off"
fi

if [[ "$show" == "on" ]]; then
  sketchybar --set "$NAME" drawing=on icon="$icon" label="${usage}%" label.drawing=on icon.padding_left=8 icon.padding_right=4
else
  # icon-only: symmetric padding to center icon in hover box (like wifi/bluetooth)
  sketchybar --set "$NAME" drawing=on icon="$icon" label="${usage}%" label.drawing=off icon.padding_left=8 icon.padding_right=8
fi
