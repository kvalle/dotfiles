#!/bin/bash

DOTFILES_PRIVILEGES_CLI=""
DOTFILES_PRIVILEGES_ACTIVE=false
DOTFILES_SUDO_KEEPALIVE_PID=""

dotfiles_privileges_begin() {
  local reason=$1

  DOTFILES_PRIVILEGES_CLI=$(command -v PrivilegesCLI 2>/dev/null) || \
    DOTFILES_PRIVILEGES_CLI="/Applications/Privileges.app/Contents/MacOS/PrivilegesCLI"

  if [[ ! -x "$DOTFILES_PRIVILEGES_CLI" ]]; then
    dotfiles_die "PrivilegesCLI ikke funnet. Kan ikke eskalere privilegier."
  fi

  trap 'dotfiles_privileges_cleanup' EXIT
  trap 'exit 130' INT
  trap 'exit 143' TERM
  DOTFILES_PRIVILEGES_ACTIVE=true
  if ! "$DOTFILES_PRIVILEGES_CLI" --add --reason "$reason"; then
    DOTFILES_PRIVILEGES_ACTIVE=false
    trap - EXIT INT TERM
    dotfiles_die "Kunne ikke aktivere midlertidige adminrettigheter."
  fi
}

dotfiles_sudo_keepalive_begin() {
  if ! sudo -v; then
    dotfiles_die "Kunne ikke autentisere sudo."
  fi
  while true; do
    sudo -v -n || exit
    sleep 50
  done 2>/dev/null &
  DOTFILES_SUDO_KEEPALIVE_PID=$!
}

dotfiles_privileges_cleanup() {
  local status=$?
  local cleanup_failed=false

  trap - EXIT INT TERM

  if [[ -n "$DOTFILES_SUDO_KEEPALIVE_PID" ]]; then
    kill "$DOTFILES_SUDO_KEEPALIVE_PID" 2>/dev/null || true
    wait "$DOTFILES_SUDO_KEEPALIVE_PID" 2>/dev/null || true
    DOTFILES_SUDO_KEEPALIVE_PID=""
    sudo -k 2>/dev/null || true
  fi

  if [[ "$DOTFILES_PRIVILEGES_ACTIVE" == true ]]; then
    if ! "$DOTFILES_PRIVILEGES_CLI" --remove; then
      dotfiles_warn "Kunne ikke fjerne midlertidige adminrettigheter."
      cleanup_failed=true
    fi
    DOTFILES_PRIVILEGES_ACTIVE=false
  fi

  if [[ "$cleanup_failed" == true && "$status" -eq 0 ]]; then
    return 1
  fi
  return "$status"
}
