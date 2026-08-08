#!/bin/bash

VERIFY_ISSUES=0

verify_pass() {
  printf '  %b✓%b  %s\n' "$GREEN" "$RESET" "$1"
}

verify_fail() {
  printf '  %b✗%b  %s\n' "$RED" "$RESET" "$1"
  VERIFY_ISSUES=$((VERIFY_ISSUES + 1))
}

verify_warn() {
  printf '  %b!%b  %s\n' "$YELLOW" "$RESET" "$1"
}

verify_header() {
  printf '\n%b%s%b\n' "$BOLD" "$1" "$RESET"
}

verify_finish() {
  (( VERIFY_ISSUES == 0 ))
}
