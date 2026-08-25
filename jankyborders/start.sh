#!/bin/bash

set -euo pipefail

NIX_PROFILE="$HOME/.local/state/nix/profiles/dotfiles"
export PATH="$NIX_PROFILE/bin:/usr/bin:/bin:/usr/sbin:/sbin"

exec >> "$HOME/Library/Logs/JankyBorders.log" 2>&1

appearance() {
  if [[ $(defaults read -g AppleInterfaceStyle 2>/dev/null) == Dark ]]; then
    printf '%s' dark
  else
    printf '%s' light
  fi
}

run_borders() {
  local mode=$1 active_color inactive_color

  if [[ $mode == dark ]]; then
    # Catppuccin Macchiato, matching Kitty's window borders.
    active_color=0xffb7bdf8
    inactive_color=0xff24273a
  else
    # Everforest Light Contrast green.
    active_color=0xff606d00
    inactive_color=0xffe4e8bd
  fi

  "$NIX_PROFILE/bin/borders" \
    active_color="$active_color" \
    inactive_color="$inactive_color" \
    width=10.0 \
    style=round \
    radius=10.0 \
    hidpi=on
}

start_borders() {
  run_borders "$1" &
  borders_pid=$!
}

update_borders() {
  run_borders "$1"
}

trap 'kill "$borders_pid" 2>/dev/null || true; wait "$borders_pid" 2>/dev/null || true; exit 0' TERM INT

mode=$(appearance)
start_borders "$mode"

while sleep 2; do
  next_mode=$(appearance)
  if ! kill -0 "$borders_pid" 2>/dev/null; then
    mode=$next_mode
    start_borders "$mode"
  elif [[ $next_mode != "$mode" ]]; then
    mode=$next_mode
    update_borders "$mode"
  fi
done
