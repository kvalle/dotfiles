#!/bin/bash

set -u

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/lib/common.sh"

dotfiles_info "Checking setup prerequisites..."

failed=()

require_command() {
  local command=$1
  local description=$2

  if command -v "$command" >/dev/null 2>&1; then
    dotfiles_success "$description"
  else
    dotfiles_warn "$description: '$command' not found"
    failed+=("$description")
  fi
}

if [[ "$(uname -s)" == Darwin ]]; then
  dotfiles_success "Operating system: macOS"
else
  dotfiles_warn "Unsupported operating system: $(uname -s) (macOS required)"
  failed+=("operating system")
fi

if [[ "$(uname -m)" == arm64 ]]; then
  dotfiles_success "Architecture: Apple Silicon"
else
  dotfiles_warn "Unsupported architecture: $(uname -m) (arm64 required)"
  failed+=("architecture")
fi

require_command git "Git"
require_command curl "curl"

if command -v xcode-select >/dev/null 2>&1 && xcode-select -p >/dev/null 2>&1; then
  dotfiles_success "Xcode Command Line Tools"
else
  dotfiles_warn "Xcode Command Line Tools not found; run 'xcode-select --install'"
  failed+=("Xcode Command Line Tools")
fi

privileges_cli=$(command -v PrivilegesCLI 2>/dev/null || true)
if [[ -z "$privileges_cli" ]]; then
  privileges_cli=/Applications/Privileges.app/Contents/MacOS/PrivilegesCLI
fi

if [[ -x "$privileges_cli" ]]; then
  dotfiles_success "PrivilegesCLI"
else
  dotfiles_warn "PrivilegesCLI not found on PATH or in /Applications/Privileges.app"
  failed+=("PrivilegesCLI")
fi

echo ""
if (( ${#failed[@]} > 0 )); then
  printf '%bPreflight failed: %s%b\n\n' "${RED}${BOLD}" "${failed[*]}" "$RESET"
  exit 1
fi

printf '%bPreflight passed.%b\n\n' "${GREEN}${BOLD}" "$RESET"
