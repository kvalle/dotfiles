#!/bin/bash

if [[ $(defaults read -g AppleInterfaceStyle 2>/dev/null) == Dark ]]; then
  background=0xff24273a
  foreground=0xffcad3f5
else
  background=0xfffffbef
  foreground=0xff3d413d
fi

sketchybar --bar color="$background" \
  --set '/.*/' icon.color="$foreground" label.color="$foreground"
