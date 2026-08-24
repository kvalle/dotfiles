#!/bin/bash

# CPU plugin — simple percentage via ps, averaged over cores.

set -u

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

sketchybar --set "$NAME" drawing=on icon="$icon" label="${usage}%"
