#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/lib/common.sh"
cd "$SCRIPT_DIR"

dotfiles_banner "setting up"

completed=()

run_setup() {
  local name=$1
  shift

  local status
  if "$@"; then
    completed+=("$name")
    return 0
  else
    status=$?
  fi
  echo ""
  printf '%bSetup failed in: %s%b\n' "${RED}${BOLD}" "$name" "$RESET"
  if (( ${#completed[@]} > 0 )); then
    printf '  Completed: %s\n' "${completed[*]}"
  fi
  printf '  Run scripts/setup.sh again after fixing the error. Completed setup steps are idempotent.\n\n'
  exit "$status"
}

run_setup "preflight" "$SCRIPT_DIR/preflight.sh"

load_nix_profile() {
  if [[ -f "$NIX_DAEMON_SCRIPT" ]]; then
    source "$NIX_DAEMON_SCRIPT"
  else
    dotfiles_warn "Nix profile script not found: $NIX_DAEMON_SCRIPT"
    dotfiles_warn "The nix command will not be on PATH - verify.sh will report it."
  fi
}

run_setup "submodule init" git -C "$DOTFILES" submodule init
run_setup "submodule update" git -C "$DOTFILES" submodule update
run_setup "brew" "$SCRIPT_DIR/brew/setup.sh"
run_setup "nix" "$SCRIPT_DIR/nix/setup.sh"

# Puts the `nix` command on PATH.
NIX_DAEMON_SCRIPT=/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
run_setup "nix profile" load_nix_profile

export PATH="$DOTFILES_NIX_PROFILE/bin:$PATH"
run_setup "rectangle" "$SCRIPT_DIR/rectangle/setup.sh"
run_setup "macos" "$SCRIPT_DIR/macos/setup.sh"
run_setup "symlinks" "$SCRIPT_DIR/symlinks/setup.sh"
run_setup "bat" "$SCRIPT_DIR/bat/setup.sh"
run_setup "skills" "$SCRIPT_DIR/skills/setup.sh"
run_setup "secrets" "$SCRIPT_DIR/secrets/setup.sh"

# Verify that everything is set up correctly
run_setup "verification" "$SCRIPT_DIR/verify.sh"

echo ""
printf '%bSetup complete - no problems found.%b\n\n' "${GREEN}${BOLD}" "$RESET"
