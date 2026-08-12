#!/bin/bash
# Dotfiles Verify - diagnostic check of the setup

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/lib/common.sh"

DOMAINS=(symlinks brew nix bat rectangle zsh secrets configs themes skills)

usage() {
  echo "Usage: ${0##*/} [all|${DOMAINS[*]}]" >&2
}

run_domain() {
  case "$1" in
    symlinks)  "$SCRIPT_DIR/symlinks/verify.sh" ;;
    brew)      "$SCRIPT_DIR/brew/verify.sh" ;;
    nix)       "$SCRIPT_DIR/nix/verify.sh" ;;
    bat)       "$SCRIPT_DIR/bat/verify.sh" ;;
    rectangle) "$SCRIPT_DIR/rectangle/verify.sh" ;;
    zsh)       "$SCRIPT_DIR/zsh/verify.sh" ;;
    secrets)   "$SCRIPT_DIR/secrets/verify.sh" ;;
    configs)   "$SCRIPT_DIR/configs/verify.sh" ;;
    themes)    "$SCRIPT_DIR/themes/verify.sh" ;;
    skills)    "$SCRIPT_DIR/skills/verify.sh" ;;
  esac
}

selection=${1:-all}
if [[ "$selection" != all && ! " ${DOMAINS[*]} " =~ " $selection " ]] || (( $# > 1 )); then
  usage
  exit 2
fi

if [[ "$selection" == all ]]; then
  dotfiles_banner "verifying"
fi

failed=()
if [[ "$selection" == all ]]; then
  for domain in "${DOMAINS[@]}"; do
    run_domain "$domain" || failed+=("$domain")
  done
else
  run_domain "$selection" || failed+=("$selection")
fi

echo ""
if (( ${#failed[@]} == 0 )); then
  printf '%bAll OK - no problems found.%b\n\n' "${GREEN}${BOLD}" "$RESET"
else
  printf '%bVerification failed for: %s%b\n\n' "${RED}${BOLD}" "${failed[*]}" "$RESET"
  exit 1
fi
