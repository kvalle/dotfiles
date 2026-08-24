#!/bin/bash

# Hover for kalender.no-knappen
if [[ "${SENDER:-}" == "mouse.entered" ]]; then
  sketchybar --set "$NAME" background.color=0x44ffffff
  exit 0
elif [[ "${SENDER:-}" == "mouse.exited" ]]; then
  sketchybar --set "$NAME" background.color=0x00000000
  exit 0
fi

sketchybar --set "$NAME" label="$(date '+%a %d %b %H:%M')"
