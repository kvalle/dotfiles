#!/bin/bash

# Memory plugin — percentage used, via memory_pressure if available.

set -u

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/plugins/common/helpers.sh"
sketchybar_handle_hover

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

# Color grading — theme-aware (same palette as appearance.sh / battery.sh)
# MEM: <70 FG, 70-85 MID, >85 RED (konservativ)
sketchybar_theme_colors

if (( usage > 85 )); then
  icon_color="$RED"
  label_color="$RED"
elif (( usage >= 70 )); then
  icon_color="$MID"
  label_color="$MID"
else
  icon_color="$FG"
  label_color="$FG"
fi

show=$(sketchybar_label_visible "$NAME" "off")
sketchybar_apply_label "$show" "$icon" "${usage}%" "$icon_color" "$label_color"
