#!/bin/bash

set -uo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/privileges.sh"

# A step that fails reports here rather than aborting: a cask that will not
# upgrade should not stop the cleanup. The exit code carries the failures up to
# scripts/update.sh, which lists the steps that went wrong.
failed=()

dotfiles_info "Updating Homebrew..."
brew update || failed+=("update")

dotfiles_info "Upgrading formulae..."
if ! brew upgrade --formula --yes; then
  dotfiles_warn "Some formulae failed to upgrade (see above for details)"
  failed+=("formulae")
fi

dotfiles_info "Upgrading casks..."
dotfiles_privileges_begin "Homebrew cask upgrade"
dotfiles_sudo_keepalive_begin

# Replacing a terminal's own app while it runs breaks the session, so the running
# terminal is held back and reported instead. kitty sets no TERM_PROGRAM —
# KITTY_PID is the documented way to detect it — while ghostty does set it.
_current_terminal_cask=""
if [[ -n "${KITTY_PID:-}" ]]; then
  _current_terminal_cask="kitty"
elif [[ "${TERM_PROGRAM:-}" == "ghostty" ]]; then
  _current_terminal_cask="ghostty"
fi

_casks_to_upgrade=()
_skipped_terminal=false
_cask_inventory_ok=false
if outdated_casks=$(brew outdated --cask --quiet); then
  _cask_inventory_ok=true
  while IFS= read -r cask; do
    [[ -n "$cask" ]] || continue
    if [[ "$cask" == "$_current_terminal_cask" ]]; then
      _skipped_terminal=true
    else
      _casks_to_upgrade+=("$cask")
    fi
  done <<< "$outdated_casks"
else
  dotfiles_warn "Could not determine which casks are outdated"
  failed+=("cask inventory")
fi

if [[ ${#_casks_to_upgrade[@]} -gt 0 ]]; then
  if ! brew upgrade --cask --yes "${_casks_to_upgrade[@]}"; then
    dotfiles_warn "Some casks failed to upgrade (see above for details)"
    failed+=("casks")
  fi
elif $_cask_inventory_ok; then
  echo "    No casks to upgrade."
fi

if $_skipped_terminal; then
  dotfiles_warn "Skipped $_current_terminal_cask (running terminal). Upgrade manually: brew upgrade --cask $_current_terminal_cask"
fi

dotfiles_privileges_cleanup || dotfiles_die "Temporary admin privileges were not revoked."

dotfiles_info "Cleaning up old versions..."
brew cleanup --prune=30 || failed+=("cleanup")

if (( ${#failed[@]} > 0 )); then
  dotfiles_warn "Homebrew had problems with: ${failed[*]}"
  exit 1
fi

if $_skipped_terminal; then
  exit "$DOTFILES_EXIT_WARNING"
fi
