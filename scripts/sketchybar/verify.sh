#!/bin/bash

set -o pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/verify-output.sh"

label="com.dotfiles.sketchybar"

verify_header "SketchyBar"

if [[ -x "$DOTFILES_NIX_PROFILE/bin/sketchybar" ]]; then
  verify_pass "Nix package"
else
  verify_fail "Nix package"
fi

if [[ -f "$HOME/Library/Fonts/sketchybar-app-font.ttf" ]]; then
  verify_pass "sketchybar-app-font"
else
  verify_fail "sketchybar-app-font (run scripts/sketchybar/setup.sh)"
fi

# icon_map.sh is generated from https://github.com/kvndrsslr/sketchybar-app-font/releases
# Regenerate: curl -fsSL https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v2.0.82/icon_map.sh -o sketchybar/plugins/icon_map.sh
if grep -q "START-OF-ICON-MAP" "$DOTFILES/sketchybar/plugins/icon_map.sh" 2>/dev/null; then
  verify_pass "icon_map.sh (generated, v2.0.82)"
else
  verify_fail "icon_map.sh (missing or not generated)"
fi

# wifi-signal helper — CoreWLAN RSSI (replaces removed `airport` CLI in Sonoma+)
# Source: sketchybar/helpers/wifi-signal.m
# Build: clang -framework CoreWLAN -framework Foundation sketchybar/helpers/wifi-signal.m -o ${XDG_CACHE_HOME:-$HOME/.cache}/sketchybar/wifi-signal
# Binary is built on demand by plugins/wifi.sh; verify checks prerequisites and freshness.
if [[ -f "$DOTFILES/sketchybar/helpers/wifi-signal.m" ]]; then
  verify_pass "wifi-signal.m (CoreWLAN helper source)"
else
  verify_fail "wifi-signal.m (missing: sketchybar/helpers/wifi-signal.m)"
fi

if command -v clang >/dev/null 2>&1; then
  verify_pass "clang (for wifi-signal helper)"
else
  verify_fail "clang (missing — install Xcode CLT: xcode-select --install)"
fi

if [[ -d "/System/Library/Frameworks/CoreWLAN.framework" ]]; then
  verify_pass "CoreWLAN.framework"
else
  verify_fail "CoreWLAN.framework (missing — not a macOS system?)"
fi

# Binary freshness — cache first, then dotfiles fallback (used inside cplt sandbox)
helper_src="$DOTFILES/sketchybar/helpers/wifi-signal.m"
helper_bin="${XDG_CACHE_HOME:-$HOME/.cache}/sketchybar/wifi-signal"
helper_fallback="$DOTFILES/sketchybar/helpers/wifi-signal"
if [[ -x "$helper_bin" ]]; then
  if [[ "$helper_src" -nt "$helper_bin" ]]; then
    verify_fail "wifi-signal binary (outdated — will rebuild on next wifi poll)"
  else
    verify_pass "wifi-signal binary (cached, up-to-date)"
  fi
elif [[ -x "$helper_fallback" ]]; then
  if [[ "$helper_src" -nt "$helper_fallback" ]]; then
    verify_fail "wifi-signal binary (dotfiles fallback outdated)"
  else
    verify_pass "wifi-signal binary (dotfiles fallback, up-to-date)"
  fi
else
  # Not yet built is not a failure — wifi.sh builds it on first run if prerequisites pass
  verify_pass "wifi-signal binary (not yet built — will auto-build)"
fi

for script in \
  "$DOTFILES/sketchybar/start.sh" \
  "$DOTFILES/sketchybar/sketchybarrc" \
  "$DOTFILES/sketchybar/plugins/"*.sh; do
  if [[ -x "$script" ]]; then
    verify_pass "${script#"$DOTFILES/"}"
  else
    verify_fail "${script#"$DOTFILES/"} (not executable)"
  fi
done

if plutil -lint "$DOTFILES/launchd/$label.plist" >/dev/null; then
  verify_pass "LaunchAgent plist"
else
  verify_fail "LaunchAgent plist"
fi

spans_displays=$(defaults read com.apple.spaces spans-displays 2>/dev/null || printf 0)
if [[ "$spans_displays" == 0 ]]; then
  verify_pass "Displays have separate Spaces"
else
  verify_fail "Displays have separate Spaces"
fi

if ! launchctl print "gui/$UID/$label" >/dev/null 2>&1; then
  verify_fail "LaunchAgent loaded"
elif "$DOTFILES_NIX_PROFILE/bin/sketchybar" --query bar >/dev/null 2>&1; then
  verify_pass "LaunchAgent loaded"
  verify_pass "Bar responding"
else
  verify_pass "LaunchAgent loaded"
  verify_fail "Bar responding (see ~/Library/Logs/SketchyBar.log)"
fi

verify_finish
