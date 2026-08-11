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

# Wordmark for the three entrypoint scripts. The caller passes what the run is
# doing — "setting up", "updating", "verifying" — and it sits above the
# wordmark, so the two read as one phrase: "updating DOTFILES".
dotfiles_banner() {
  local subtitle=$1
  local muted='\033[38;2;128;128;128m'   # #808080
  local bright='\033[38;2;238;238;238m'  # #eeeeee

  echo ""
  printf '  %b\n' "${DIM}${subtitle}${RESET}"
  printf '  %b\n' "${bright}${BOLD}█▀▀▄ █▀▀█ ▀▀█▀▀ █▀▀▀ █ █    █▀▀▀ █▀▀▀${RESET}"
  printf '  %b\n' "${muted}█  █ █  █   █   █▀▀▀ █ █    █▀▀▀ ▀▀▀█${RESET}"
  printf '  %b\n' "${muted}▀▀▀  ▀▀▀▀   ▀   ▀    ▀ ▀▀▀▀ ▀▀▀▀ ▀▀▀▀${RESET}"
  echo ""
}

dotfiles_info() {
  printf '\n%b\n' "${BOLD}${BLUE}▸ ${RESET}${BOLD}$1${RESET}"
}

dotfiles_warn() {
  printf '%b\n' "    ${BOLD}${YELLOW}WARNING:${RESET} $1"
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

# Put fnm's Node (and npm/npx) on PATH for the rest of the script.
#
# fnm comes from Nix, but ships no Node version until one is installed — and
# these scripts run in bash, where zsh/tools.sh has not been evaluated. So both
# steps happen here: install the latest LTS if there is no `default` yet (fnm
# sets that alias itself on the first install), then apply `fnm env`.
#
# Returns non-zero when fnm is missing or no Node could be provided, so callers
# can decide whether to skip or fall back to whatever is already on PATH.
dotfiles_use_node() {
  command -v fnm >/dev/null 2>&1 || return 1
  fnm exec --using=default -- true 2>/dev/null || fnm install --lts || return 1
  eval "$(fnm env --shell bash)"
}
