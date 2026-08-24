#!/bin/bash

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/plugins/common/helpers.sh"
sketchybar_handle_hover

sketchybar --set "$NAME" label="$(date '+%a %d %b %H:%M')"
