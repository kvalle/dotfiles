#!/bin/bash

set -o pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/verify-output.sh"

verify_header "Shell scripts"

if ! command -v shellcheck >/dev/null 2>&1; then
  verify_fail "ShellCheck is not installed"
  verify_finish
  exit $?
fi

shell_files=()
while IFS= read -r file; do
  shell_files+=("$file")
done < <(find "$DOTFILES/scripts" "$DOTFILES/bin" "$DOTFILES/tuna/scripts" \
  -type f -perm -u+x -print)

if output=$(shellcheck --severity=warning --exclude=SC1090 "${shell_files[@]}" 2>&1); then
  verify_pass "ShellCheck"
else
  verify_fail "ShellCheck"
  [ -z "$output" ] || sed 's/^/      /' <<< "$output"
fi

verify_finish
