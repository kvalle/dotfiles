#!/bin/bash

# CPU plugin — simple percentage via ps, averaged over cores.

set -u

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/plugins/helpers.sh"
sketchybar_handle_hover

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
sketchybar_apply_label "$show" "$icon" "${usage}%" "$icon_color" "$label_color"
