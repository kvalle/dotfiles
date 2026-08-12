#!/bin/bash

set -o pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/verify-output.sh"

CONFIG="$DOTFILES/rectangle/RectangleConfig.json"
IMPORT_PATH="$HOME/Library/Application Support/Rectangle/RectangleConfig.json"

verify_header "Rectangle"

if ! command -v jq >/dev/null 2>&1; then
  verify_warn "RectangleConfig.json (jq is not installed)"
elif jq empty "$CONFIG" 2>/dev/null; then
  verify_pass "RectangleConfig.json is valid JSON"
else
  verify_fail "RectangleConfig.json is not valid JSON"
fi

# setup.sh copies the config to Rectangle's import path, and Rectangle renames it
# with a timestamp once it has read it (docs/setup/rectangle.md). A file still
# sitting there has not reached Rectangle yet — and if it no longer matches the
# repo, the next launch imports the wrong configuration.
if [ -f "$IMPORT_PATH" ]; then
  if cmp -s "$CONFIG" "$IMPORT_PATH"; then
    verify_warn "config is waiting to be imported (restart Rectangle)"
  else
    verify_fail "the copy at the import path differs from the repo (run scripts/rectangle/setup.sh)"
  fi
fi

verify_finish
