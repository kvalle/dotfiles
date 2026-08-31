#!/bin/bash

# Memory plugin — percentage used, via memory_pressure query mode if available.

set -u

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/plugins/common/helpers.sh"
sketchybar_handle_hover mem.background

# mem.graph uses this script only to forward hover events to the shared bracket.
if [[ "$NAME" == "mem.graph" ]]; then
  exit 0
fi

usage=""

# Query mode prints "System-wide memory free percentage: 42%" and exits.
if command -v memory_pressure >/dev/null 2>&1; then
  pressure_output=$(memory_pressure -Q 2>/dev/null || true)
  if [[ "$pressure_output" =~ System-wide\ memory\ free\ percentage:\ ([0-9]+)% ]]; then
    free_pct="${BASH_REMATCH[1]}"
  else
    free_pct=""
  fi
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
if [[ "$show" == "on" ]]; then
  icon_padding_right=2
else
  icon_padding_right=8
fi
sketchybar --set "$NAME" drawing=on icon="$icon" icon.color="$icon_color" \
  icon.padding_right="$icon_padding_right" label.drawing=off

graph_fill="${icon_color:0:2}33${icon_color:4}"
sketchybar --push mem.graph "$(awk -v u="$usage" 'BEGIN { printf "%.2f", u / 100 }')" \
  --set mem.graph drawing="$show" label="${usage}%" label.color="$label_color" \
  graph.color="$icon_color" graph.fill_color="$graph_fill"
