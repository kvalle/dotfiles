#!/bin/bash

# Volume plugin — event-driven via volume_change, fallback polling.
# Sources: volume level (0-100) and mute state from macOS.

set -u

# Prefer event payload, fall back to querying the system.
if [[ -n "${INFO:-}" ]]; then
  volume="$INFO"
else
  volume=$(osascript -e 'output volume of (get volume settings)' 2>/dev/null || echo "")
fi

muted=$(osascript -e 'output muted of (get volume settings)' 2>/dev/null || echo "false")

if [[ -z "$volume" ]]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

# Coerce to integer (INFO can be "50" already)
volume_int=${volume%%%*}
if ! [[ "$volume_int" =~ ^[0-9]+$ ]]; then
  volume_int=0
fi

if [[ "$muted" == "true" ]] || (( volume_int == 0 )); then
  icon="󰖁"
elif (( volume_int <= 30 )); then
  icon="󰕿"
elif (( volume_int <= 60 )); then
  icon="󰖀"
else
  icon="󰕾"
fi

sketchybar --set "$NAME" drawing=on icon="$icon" label="${volume_int}%"
