#!/bin/bash

# Wi-Fi plugin — icon-only, hover shows clickability.
# Determines SSID/connected state via multiple methods (ipconfig, networksetup, CoreWLAN)
# to handle redacted SSID, 6GHz networksetup bug, and removed `airport` CLI (Sonoma+).
# Event wifi_change is broken since Sonoma, so we poll (update_freq=10).
# Signal strength is shown via tiered icons using RSSI from CoreWLAN (native/wifi-signal.m).
# Fallback is generic 󰖩/󰖪 when the helper cannot be built.

set -u

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/plugins/common/helpers.sh"
sketchybar_handle_hover

# ── Signal strength via CoreWLAN helper ──────────────────────────────
# Helper source: $CONFIG_DIR/native/wifi-signal.m
# Binary candidates (first executable wins):
#   1. ${XDG_CACHE_HOME:-$HOME/.cache}/sketchybar/wifi-signal  (standard cache)
#   2. $CONFIG_DIR/native/wifi-signal                         (dotfiles fallback, works inside cplt sandbox)
wifi_rssi=""
wifi_helper_src="$CONFIG_DIR/native/wifi-signal.m"
wifi_helper_candidates=(
  "${XDG_CACHE_HOME:-$HOME/.cache}/sketchybar/wifi-signal"
  "$CONFIG_DIR/native/wifi-signal"
)
# Auto-build helper if source is newer than any candidate (requires Xcode CLT).
# Prefer cache location, but fall back to dotfiles location if cache not writable/executable.
if [[ -f "$wifi_helper_src" ]]; then
  for wifi_bin in "${wifi_helper_candidates[@]}"; do
    if [[ ! -x "$wifi_bin" || "$wifi_helper_src" -nt "$wifi_bin" ]]; then
      mkdir -p "$(dirname "$wifi_bin")" 2>/dev/null || true
      if clang -framework CoreWLAN -framework Foundation "$wifi_helper_src" -o "$wifi_bin" 2>/dev/null; then
        chmod +x "$wifi_bin" 2>/dev/null || true
        # If this candidate is now executable, break — we have a usable binary
        if [[ -x "$wifi_bin" ]]; then
          break
        fi
      fi
    else
      # Already up-to-date and executable
      break
    fi
  done
fi
# Try each candidate until one executes successfully
for wifi_bin in "${wifi_helper_candidates[@]}"; do
  if [[ -x "$wifi_bin" ]]; then
    wifi_rssi=$("$wifi_bin" 2>/dev/null || true)
    wifi_rssi=$(printf '%s' "$wifi_rssi" | tr -d ' \t\r\n')
    if [[ -n "$wifi_rssi" ]]; then
      break
    fi
  fi
done

# If helper gave us a usable result, map RSSI → icon and exit early.
# Numeric RSSI is negative dBm (e.g. -54). Thresholds follow Apple's guidance:
#   >= -50 excellent, >= -60 good, >= -67 fair (roaming threshold), >= -75 weak.
if [[ -n "$wifi_rssi" ]]; then
  case "$wifi_rssi" in
    off|disconnected|no-iface)
      sketchybar --set "$NAME" drawing=on icon="󰖪" label.drawing=off
      exit 0
      ;;
    -*)
      # Numeric — verify it is an integer
      if [[ "$wifi_rssi" =~ ^-[0-9]+$ ]]; then
        rssi_val=$wifi_rssi
        if (( rssi_val >= -50 )); then
          icon="󰤨"  # mdi:wifi-strength-4 — excellent
        elif (( rssi_val >= -60 )); then
          icon="󰤥"  # mdi:wifi-strength-3 — good
        elif (( rssi_val >= -67 )); then
          icon="󰤢"  # mdi:wifi-strength-2 — fair
        elif (( rssi_val >= -75 )); then
          icon="󰤟"  # mdi:wifi-strength-1 — weak
        else
          icon="󰤟"  # very weak (same glyph, could use 󰤫 alert if desired)
        fi
        sketchybar --set "$NAME" drawing=on icon="$icon" label.drawing=off
        exit 0
      fi
      ;;
  esac
  # If helper returned something unexpected, fall through to SSID fallback.
fi

ssid=""

# Prefer event payload if provided (wifi_change may give SSID)
if [[ -n "${INFO:-}" && "$INFO" != "off" ]]; then
  ssid="$INFO"
fi

# Method 1: airport tool — try both old and new locations
if [[ -z "$ssid" ]]; then
  for airport in \
    "/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport" \
    "/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport" \
    "/usr/sbin/airport" \
    "$(which airport 2>/dev/null || true)"; do
    if [[ -x "$airport" ]]; then
      ssid=$("$airport" -I 2>/dev/null | awk -F': ' '/^[[:space:]]*SSID:/ {print $2; exit}' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
      if [[ "$ssid" == "off" || "$ssid" == "<redacted>" || "$ssid" == "<unknown>" || "$ssid" == *"<"* ]]; then
        ssid=""
      else
        break
      fi
    fi
  done
fi

# Method 2: ipconfig getsummary — works even when networksetup says "not associated" (6GHz bug)
if [[ -z "$ssid" ]]; then
  for dev in en0 en1 en2; do
    raw=$(ipconfig getsummary "$dev" 2>/dev/null | grep -m1 "SSID :" || true)
    if [[ -n "$raw" ]]; then
      ssid=$(printf '%s' "$raw" | sed 's/.*SSID : //;s/^[[:space:]]*//;s/[[:space:]]*$//')
      if [[ -n "$ssid" && "$ssid" != "<redacted>" && "$ssid" != *"<"* ]]; then
        break
      else
        ssid=""
      fi
    fi
  done
fi

# Method 3: networksetup for en0/en1/en2 (fallback)
if [[ -z "$ssid" ]]; then
  for dev in en0 en1 en2; do
    raw=$(networksetup -getairportnetwork "$dev" 2>/dev/null || true)
    if [[ "$raw" == Current* ]]; then
      ssid=${raw#Current Wi-Fi Network: }
      ssid=$(printf '%s' "$ssid" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
      if [[ "$ssid" == "<redacted>" || "$ssid" == *"<"* ]]; then
        ssid=""
        continue
      fi
      break
    fi
  done
fi

# Method 4: defaults com.apple.airport.preferences — last resort (cached SSID)
if [[ -z "$ssid" ]]; then
  ssid=$(defaults read /Library/Preferences/SystemConfiguration/com.apple.airport.preferences 2>/dev/null | grep -m1 "SSIDString" | sed 's/.*SSIDString[^"]*"//;s/".*//' || true)
  if [[ "$ssid" == "<redacted>" || "$ssid" == *"<"* ]]; then
    ssid=""
  fi
fi

# Determine if Wi-Fi is actually connected even when SSID is redacted (macOS privacy)
wifi_connected=false
if [[ -z "$ssid" ]]; then
  # system_profiler Status: Connected is reliable even when SSID is <redacted>
  if system_profiler SPAirPortDataType 2>/dev/null | grep -q "Status: Connected"; then
    wifi_connected=true
  elif ifconfig en0 2>/dev/null | grep -q "status: active"; then
    wifi_connected=true
  fi
fi

if [[ -z "$ssid" ]]; then
  if [[ "$wifi_connected" == true ]]; then
    icon="󰖩"
  else
    icon="󰖪"
  fi
else
  icon="󰖩"
fi
# Ikon-only (label skjules via sketchybarrc label.drawing=off) — behold label for a11y men vis ikke
sketchybar --set "$NAME" drawing=on icon="$icon" label.drawing=off
