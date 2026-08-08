#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/privileges.sh"

dotfiles_info "Oppdaterer Homebrew..."
brew update

dotfiles_info "Oppgraderer formulae..."
if ! brew upgrade --formula --yes; then
  dotfiles_warn "Noen formulae feilet under oppgradering (se over for detaljer)"
fi

dotfiles_info "Oppgraderer casks..."
dotfiles_privileges_begin "Homebrew cask upgrade"
dotfiles_sudo_keepalive_begin

_excluded_casks=()
while IFS= read -r line; do
  cask=$(echo "$line" | sed -n 's/^cask "\([^"]*\)".*/\1/p')
  [[ -n "$cask" ]] && _excluded_casks+=("$cask")
done < <(grep '\[self-updates\]' "$DOTFILES/Brewfile")

_current_terminal_cask=""
case "${TERM_PROGRAM:-}" in
  ghostty) _current_terminal_cask="ghostty" ;;
  kitty)   _current_terminal_cask="kitty" ;;
esac

_outdated_casks=$(brew outdated --cask --quiet)
_to_upgrade=()
_skipped_terminal=false
for cask in $_outdated_casks; do
  _skip=false
  for excluded in "${_excluded_casks[@]}"; do
    [[ "$cask" == "$excluded" ]] && _skip=true && break
  done
  if [[ "$cask" == "$_current_terminal_cask" ]]; then
    _skip=true
    _skipped_terminal=true
  fi
  $_skip || _to_upgrade+=("$cask")
done

if [[ ${#_to_upgrade[@]} -gt 0 ]]; then
  if ! brew upgrade --cask --yes "${_to_upgrade[@]}"; then
    dotfiles_warn "Noen casks feilet under oppgradering (se over for detaljer)"
  fi
else
  echo "    Fant ingen casks å oppgradere."
fi

if $_skipped_terminal; then
  dotfiles_warn "Hoppet over $_current_terminal_cask (kjørende terminal). Oppgrader manuelt: brew upgrade --cask $_current_terminal_cask"
fi

dotfiles_privileges_cleanup || dotfiles_die "Midlertidige adminrettigheter ble ikke fjernet."

dotfiles_info "Rydder gamle versjoner..."
brew cleanup --prune=30
