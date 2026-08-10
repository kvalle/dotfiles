#!/bin/bash

# Sourced scripts choose their own error policy before loading this file.
DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
export DOTFILES

BOLD='\033[1m'
DIM='\033[2m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

dotfiles_info() {
  printf '\n%b\n' "${BOLD}${BLUE}▸ ${RESET}${BOLD}$1${RESET}"
}

dotfiles_warn() {
  printf '%b\n' "    ${BOLD}${YELLOW}ADVARSEL:${RESET} $1"
}

dotfiles_success() {
  printf '%b\n' "    ${GREEN}✓${RESET}  $1"
}

# /dev/tty can exist, with permission bits that look right, without the process
# having a controlling terminal. open() then fails with ENXIO, so the only
# reliable test is to actually open it.
dotfiles_tty_available() {
  { true > /dev/tty; } 2>/dev/null
}

# Ask a yes/no question. Returns 0 on yes, 1 on no, and 2 when there is no
# terminal to ask in, so callers can tell a refusal from an impossible question.
# Reads from /dev/tty rather than stdin: callers are usually inside a loop that
# is already consuming stdin.
dotfiles_confirm() {
  local prompt=$1 answer=""

  dotfiles_tty_available || return 2

  printf '    %s [y/N] ' "$prompt" > /dev/tty
  read -r answer < /dev/tty || return 1
  [[ "$answer" =~ ^[Yy]$ ]]
}

dotfiles_die() {
  dotfiles_warn "$1" >&2
  exit 1
}
