#!/bin/bash

# CPU plugin — simple percentage via ps, averaged over cores.

set -u

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/plugins/common/helpers.sh"
sketchybar_handle_hover cpu.background

# cpu.graph uses this script only to forward hover events to the shared bracket.
if [[ "$NAME" == "cpu.graph" ]]; then
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
sketchybar_theme_colors

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

show=$(sketchybar_label_visible "$NAME" "off")
sketchybar --set "$NAME" drawing=on icon="$icon" icon.color="$icon_color" label.drawing=off

graph_fill="${icon_color:0:2}33${icon_color:4}"
sketchybar --push cpu.graph "$(awk -v u="$usage" 'BEGIN { printf "%.2f", u / 100 }')" \
  --set cpu.graph drawing="$show" label="${usage}%" label.color="$label_color" \
  graph.color="$icon_color" graph.fill_color="$graph_fill"
