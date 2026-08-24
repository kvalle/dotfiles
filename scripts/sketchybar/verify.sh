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
