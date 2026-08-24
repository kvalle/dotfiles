#!/bin/bash

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/plugins/helpers.sh"
sketchybar_handle_hover

percentage=$(pmset -g batt | grep -Eo '[0-9]+%' | tr -d '%' || true)
charging=$(pmset -g batt | grep -q 'AC Power' && printf true || printf false)

if [[ -z "$percentage" ]]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

if [[ "$charging" == true ]]; then
  icon="󰂄"
elif (( percentage <= 20 )); then
  icon="󰁺"
elif (( percentage <= 50 )); then
  icon="󰁾"
elif (( percentage <= 80 )); then
  icon="󰂁"
else
  icon="󰁹"
fi

sketchybar_theme_colors

if (( percentage <= 20 )); then
  icon_color="$RED"
  label_color="$RED"
elif [[ "$charging" == true ]] || (( percentage > 50 )); then
  icon_color="$FG"
  label_color="$FG"
else
  icon_color="$MID"
  label_color="$MID"
fi

show=$(sketchybar_label_visible "$NAME" "on")
sketchybar_apply_label "$show" "$icon" "${percentage}%" "$icon_color" "$label_color"
