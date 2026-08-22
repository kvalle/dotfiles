#!/bin/bash

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

sketchybar --set "$NAME" drawing=on icon="$icon" label="${percentage}%"
