#!/bin/bash

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/plugins/common/helpers.sh"

if sketchybar_is_dark; then
  background=0xff24273a
  foreground=0xffb7bdf8
else
  background=0xffe4e8bd
  foreground=0xff3d413d
fi

sketchybar --bar color="$background" \
  --set '/.*/' icon.color="$foreground" label.color="$foreground"
