#!/bin/bash

# Bluetooth plugin — shows power/connection state.
# Prefers blueutil if installed (faster), falls back to system_profiler.

set -u

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/plugins/helpers.sh"
sketchybar_handle_hover

icon="󰂯"
powered="unknown"
connected_count=0

if command -v blueutil >/dev/null 2>&1; then
  power_val=$(blueutil --power 2>/dev/null | tr -d '[:space:]' || true)
  if [[ "$power_val" == "1" ]]; then
    powered="on"
  elif [[ "$power_val" == "0" ]]; then
    powered="off"
  fi
  if [[ "$powered" == "on" ]]; then
    # Count connected devices (lines with "connected")
    connected_count=$(blueutil --connected 2>/dev/null | grep -c "connected" || true)
    # blueutil --connected may list nothing when none connected
    if [[ -z "$connected_count" ]]; then
      connected_count=0
    fi
  elif [[ "$powered" == "unknown" ]]; then
    # blueutil failed (no permission / unexpected output) — fall back to system_profiler
    bt_info=$(system_profiler SPBluetoothDataType 2>/dev/null || true)
    if echo "$bt_info" | grep -q "Bluetooth Power: On"; then
      powered="on"
      connected_count=$(echo "$bt_info" | grep -c "Connected: Yes" || true)
    elif echo "$bt_info" | grep -q "Bluetooth Power: Off"; then
      powered="off"
    fi
  fi
else
  # Fallback: system_profiler (slower, ~0.3s)
  bt_info=$(system_profiler SPBluetoothDataType 2>/dev/null || true)
  if echo "$bt_info" | grep -q "Bluetooth Power: On"; then
    powered="on"
  elif echo "$bt_info" | grep -q "Bluetooth Power: Off"; then
    powered="off"
  fi
  if [[ "$powered" == "on" ]]; then
    connected_count=$(echo "$bt_info" | grep -c "Connected: Yes" || true)
  fi
fi

# Final safety: if still unknown, treat as off to avoid false "on"
if [[ "$powered" == "unknown" ]]; then
  # Re-check via system_profiler once more
  bt_info=$(system_profiler SPBluetoothDataType 2>/dev/null || true)
  if echo "$bt_info" | grep -q "Bluetooth Power: Off"; then
    powered="off"
  elif echo "$bt_info" | grep -q "Bluetooth Power: On"; then
    powered="on"
  else
    powered="off"
  fi
fi

if [[ "$powered" == "off" ]]; then
  icon="󰂲"
else
  # Ikon-only — vis kun ikon, ingen tekst (hover viser klikkbarhet)
  if (( connected_count > 0 )); then
    icon="󰂱"
  else
    icon="󰂯"
  fi
fi
sketchybar --set "$NAME" drawing=on icon="$icon" label.drawing=off
