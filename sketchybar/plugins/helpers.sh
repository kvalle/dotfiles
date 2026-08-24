#!/bin/bash
# helpers.sh — shared helpers for sketchybar plugins.
# Source only; do not execute directly.
# Sourced as: source "$CONFIG_DIR/plugins/helpers.sh"
# Freshness: no generation step, hand-maintained alongside plugins.

# Returns 0 if macOS is in Dark Mode, 1 otherwise.
sketchybar_is_dark() {
  [[ $(defaults read -g AppleInterfaceStyle 2>/dev/null) == Dark ]]
}

# Handles hover feedback for clickable items. Exits the caller on
# mouse.entered / mouse.exited so the plugin does not continue.
# Theme-aware: light overlay on dark, dark overlay on light.
sketchybar_handle_hover() {
  case "${SENDER:-}" in
    mouse.entered)
      if sketchybar_is_dark; then
        sketchybar --set "$NAME" background.color=0x44ffffff
      else
        sketchybar --set "$NAME" background.color=0x33000000
      fi
      exit 0
      ;;
    mouse.exited)
      sketchybar --set "$NAME" background.color=0x00000000
      exit 0
      ;;
  esac
}

# Sets FG, RED, MID globals to the shared Catppuccin-derived palette.
# Same palette used in battery.sh / cpu.sh / mem.sh / appearance.sh.
sketchybar_theme_colors() {
  if sketchybar_is_dark; then
    FG=0xffcad3f5
    RED=0xffed8796
    MID=0xfff5a97f
  else
    FG=0xff3d413d
    RED=0xffd20f39
    MID=0xfffe640b
  fi
}

# Prints "on" or "off" for label visibility, persisted by toggle-label.sh.
# $1 = item name ($NAME), $2 = default ("on" or "off")
sketchybar_label_visible() {
  local name="$1"
  local default_val="$2"
  local file="${XDG_CACHE_HOME:-$HOME/.cache}/sketchybar/$name.show"
  local val=""
  if [[ -f "$file" ]]; then
    val=$(cat "$file" 2>/dev/null || printf '%s' "$default_val")
  else
    val="$default_val"
  fi
  if [[ "$val" != "on" && "$val" != "off" ]]; then
    val="$default_val"
  fi
  printf '%s' "$val"
}

# Applies icon/label with correct padding and colors.
# Keeps label.drawing=on and animates label.width 0 <-> dynamic for a smooth
# slide; icon padding animates together.
# $1 = on|off, $2 = icon, $3 = label, $4 = icon_color, $5 = label_color
sketchybar_apply_label() {
  local show="$1" icon="$2" label="$3" icon_color="$4" label_color="$5"
  if [[ "$show" == "on" ]]; then
    sketchybar --set "$NAME" drawing=on icon="$icon" label="$label" label.drawing=on label.width=dynamic icon.padding_left=8 icon.padding_right=4 icon.color="$icon_color" label.color="$label_color"
  else
    # icon-only: symmetric padding + width 0 hides label but keeps it animatable
    sketchybar --set "$NAME" drawing=on icon="$icon" label="$label" label.drawing=on label.width=0 icon.padding_left=8 icon.padding_right=8 icon.color="$icon_color" label.color="$label_color"
  fi
}
