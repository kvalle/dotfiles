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

dotfiles_die() {
  dotfiles_warn "$1" >&2
  exit 1
}
