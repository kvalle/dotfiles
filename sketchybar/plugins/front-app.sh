#!/bin/bash

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/plugins/common/icon_map.sh"

app=${INFO:-}
if [[ -z "$app" ]]; then
  app=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true')
fi

__icon_map "$app"
icon="${icon_result:-:default:}"

sketchybar --set "$NAME" icon="$icon" label="$app"
