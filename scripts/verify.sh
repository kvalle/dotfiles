#!/bin/bash
# Dotfiles Verify - diagnostic check of the setup

set -o pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/lib/common.sh"

DOMAINS=()
for script in "$SCRIPT_DIR"/*/verify.sh; do
  [[ -x "$script" ]] || continue   # also skips the unexpanded glob if none match
  domain=${script%/verify.sh}
  DOMAINS+=("${domain##*/}")
done

usage() {
  echo "Usage: ${0##*/} [all|${DOMAINS[*]}]" >&2
}

if (( ${#DOMAINS[@]} == 0 )); then
  dotfiles_die "Found no verify scripts in $SCRIPT_DIR"
fi

selection=${1:-all}
if (( $# > 1 )) || [[ "$selection" != all && " ${DOMAINS[*]} " != *" $selection "* ]]; then
  usage
  exit 2
fi

if [[ "$selection" == all ]]; then
  dotfiles_banner "verifying"
  targets=("${DOMAINS[@]}")
else
  targets=("$selection")
fi

failed=()
for domain in "${targets[@]}"; do
  "$SCRIPT_DIR/$domain/verify.sh" || failed+=("$domain")
done

echo ""
if (( ${#failed[@]} == 0 )); then
  printf '%bAll OK - no problems found.%b\n\n' "${GREEN}${BOLD}" "$RESET"
else
  printf '%bVerification failed for: %s%b\n\n' "${RED}${BOLD}" "${failed[*]}" "$RESET"
  exit 1
fi
