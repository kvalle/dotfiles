#!/bin/bash

set -o pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/verify-output.sh"

verify_header "Agent skills"

# manifest.sh --check writes the diff to stdout and its explanation to stderr,
# so both are captured and reported under the failing line.
if output=$("$SCRIPT_DIR/manifest.sh" --check 2>&1); then
  verify_pass "ai/skills.txt is up to date"
else
  verify_fail "ai/skills.txt does not match the skill lockfile"
  [ -z "$output" ] || sed 's/^/      /' <<< "$output"
fi

verify_finish
