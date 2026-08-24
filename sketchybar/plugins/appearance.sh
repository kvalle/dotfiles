#!/bin/bash

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/plugins/helpers.sh"

if sketchybar_is_dark; then
  background=0xff24273a
  foreground=0xffcad3f5
else
  background=0xfffffbef
  foreground=0xff3d413d
fi

sketchybar --bar color="$background" \
  --set '/.*/' icon.color="$foreground" label.color="$foreground"
