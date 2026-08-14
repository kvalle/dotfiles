#!/bin/bash

set -o pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/verify-output.sh"
source "$SCRIPT_DIR/common.sh"

verify_header "Agent skills"

# manifest.sh --check writes the diff to stdout and its explanation to stderr,
# so both are captured and reported under the failing line. Its exit code says
# which of the three failures it was; see common.sh.
output=$("$SCRIPT_DIR/manifest.sh" --check 2>&1)
case $? in
  0)
    verify_pass "ai/skills.txt is up to date"
    ;;
  "$SKILLS_EXIT_DRIFT")
    verify_fail "ai/skills.txt does not match the skill lockfile"
    ;;
  "$SKILLS_EXIT_NO_LOCK")
    verify_fail "The skill lockfile is missing, so no skills are installed"
    ;;
  "$SKILLS_EXIT_INVALID_LOCK")
    verify_fail "The skill lockfile is not a valid skill lockfile"
    ;;
  *)
    verify_fail "manifest.sh --check failed for an unknown reason"
    ;;
esac

[ -z "$output" ] || sed 's/^/      /' <<< "$output"

verify_finish
