#!/bin/bash

# Hover for kalender.no-knappen — theme-aware (hvit på mørk, mørk på lys)
if [[ "${SENDER:-}" == "mouse.entered" ]]; then
  if [[ $(defaults read -g AppleInterfaceStyle 2>/dev/null) == Dark ]]; then
    sketchybar --set "$NAME" background.color=0x44ffffff
  else
    sketchybar --set "$NAME" background.color=0x33000000
  fi
  exit 0
elif [[ "${SENDER:-}" == "mouse.exited" ]]; then
  sketchybar --set "$NAME" background.color=0x00000000
  exit 0
fi

sketchybar --set "$NAME" label="$(date '+%a %d %b %H:%M')"
