#!/bin/bash

# Wi-Fi plugin — icon-only, hover shows clickability.
# Determines SSID/connected state via multiple methods (airport, ipconfig, networksetup)
# to handle redacted SSID and 6GHz networksetup bug. Event wifi_change is broken
# since Sonoma, so we poll.

set -u

# Hover — vis at det kan trykkes — theme-aware
if [[ "${SENDER:-}" == "mouse.entered" ]]; then
  if [[ $(defaults read -g AppleInterfaceStyle 2>/dev/null) == Dark ]]; then
    sketchybar --set "$NAME" background.color=0x44ffffff
  else
    sketchybar --set "$NAME" background.color=0x33000000
  fi
  exit 0
elif [[ "${SENDER:-}" == "mouse.exited" ]]; then
  sketchybar --set "$NAME" background.color=0x00000000
  exit 0
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
