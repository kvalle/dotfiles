#!/bin/bash

# Volume plugin — event-driven via volume_change, fallback polling.
# Sources: volume level (0-100) and mute state from macOS.

set -u

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/plugins/helpers.sh"
sketchybar_handle_hover

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

if [[ "$muted" == "true" ]]; then
  icon="󰖁"
elif (( volume_int == 0 )); then
  icon="󰖁"
elif (( volume_int <= 30 )); then
  icon="󰕿"
elif (( volume_int <= 60 )); then
  icon="󰖀"
else
  icon="󰕾"
fi

sketchybar_theme_colors
icon_color="$FG"
label_color="$FG"

show=$(sketchybar_label_visible "$NAME" "on")
sketchybar_apply_label "$show" "$icon" "${volume_int}%" "$icon_color" "$label_color"
