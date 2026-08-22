#!/bin/bash

app=${INFO:-}
if [[ -z "$app" ]]; then
  app=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true')
fi

sketchybar --set "$NAME" label="$app"
