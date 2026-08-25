#!/bin/bash

set -o pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/verify-output.sh"

label="com.dotfiles.jankyborders"

verify_header "JankyBorders"

if [[ -x "$DOTFILES_NIX_PROFILE/bin/borders" ]]; then
  verify_pass "Nix package"
else
  verify_fail "Nix package"
fi

if [[ -x "$DOTFILES/jankyborders/start.sh" ]]; then
  verify_pass "jankyborders/start.sh"
else
  verify_fail "jankyborders/start.sh (not executable)"
fi

if plutil -lint "$DOTFILES/launchd/$label.plist" >/dev/null; then
  verify_pass "LaunchAgent plist"
else
  verify_fail "LaunchAgent plist"
fi

if ! launchctl print "gui/$UID/$label" >/dev/null 2>&1; then
  verify_fail "LaunchAgent loaded"
elif pgrep -x borders >/dev/null 2>&1; then
  verify_pass "LaunchAgent loaded"
  verify_pass "Borders running"
else
  verify_pass "LaunchAgent loaded"
  verify_fail "Borders running (see ~/Library/Logs/JankyBorders.log)"
fi

verify_finish
