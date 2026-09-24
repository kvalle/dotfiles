#!/bin/bash

set -o pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/verify-output.sh"

PREFERENCES=$(defaults export com.apple.symbolichotkeys - 2>/dev/null || true)

preference_value() {
  plutil -extract "$1" raw - 2>/dev/null <<< "$PREFERENCES"
}

preference_has_type() {
  [ "$(plutil -type "$1" - 2>/dev/null <<< "$PREFERENCES")" = "$2" ]
}

verify_header "macOS"

spotlight_enabled=$(preference_value AppleSymbolicHotKeys.64.enabled || true)
spotlight_character=$(preference_value AppleSymbolicHotKeys.64.value.parameters.0 || true)
spotlight_key_code=$(preference_value AppleSymbolicHotKeys.64.value.parameters.1 || true)
spotlight_modifiers=$(preference_value AppleSymbolicHotKeys.64.value.parameters.2 || true)

if preference_has_type AppleSymbolicHotKeys.64.enabled bool && \
    preference_has_type AppleSymbolicHotKeys.64.value.parameters.0 integer && \
    preference_has_type AppleSymbolicHotKeys.64.value.parameters.1 integer && \
    preference_has_type AppleSymbolicHotKeys.64.value.parameters.2 integer && \
    [[ "$spotlight_enabled" == true && "$spotlight_character" == 32 && \
       "$spotlight_key_code" == 49 && "$spotlight_modifiers" == 1572864 ]]; then
  verify_pass "Spotlight uses cmd+option+space"
else
  verify_fail "Spotlight shortcut (run scripts/macos/setup.sh, then log out and back in)"
fi

finder_search_enabled=$(preference_value AppleSymbolicHotKeys.65.enabled || true)
if preference_has_type AppleSymbolicHotKeys.65.enabled bool && \
    [[ "$finder_search_enabled" == false ]]; then
  verify_pass "Finder search shortcut is disabled"
else
  verify_fail "Finder search conflicts with cmd+option+space (run scripts/macos/setup.sh)"
fi

verify_finish
