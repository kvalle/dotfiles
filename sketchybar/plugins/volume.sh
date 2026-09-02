#!/bin/bash

# Volume plugin — event-driven via volume_change, fallback polling.
# Sources: volume level (0-100) and mute state from macOS.

set -u

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/plugins/common/helpers.sh"
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
if [[ "$muted" == "true" ]]; then
  icon_color="$FG"
  label_color="$FG"
else
  icon_color="$MID"
  label_color="$MID"
fi

show=$(sketchybar_label_visible "$NAME" "on")
if [[ "$muted" == "true" ]]; then
  # Show 0% with mute icon when toggle is on – consistent with volume==0 behaviour.
  sketchybar_apply_label "$show" "$icon" "0%" "$icon_color" "$label_color"
  exit 0
fi
sketchybar_apply_label "$show" "$icon" "${volume_int}%" "$icon_color" "$label_color"
