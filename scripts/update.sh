#!/bin/bash

DOTFILES_DIR="$HOME/dotfiles"
PRIVILEGES_CLI=$(command -v PrivilegesCLI 2>/dev/null) || \
  PRIVILEGES_CLI="/Applications/Privileges.app/Contents/MacOS/PrivilegesCLI"

if [[ ! -x "$PRIVILEGES_CLI" ]]; then
  warn "PrivilegesCLI ikke funnet. Kan ikke eskalere privilegier."
  exit 1
fi

# --------------------------------------------------------------------------
# Farger og formatering
# --------------------------------------------------------------------------

BOLD='\033[1m'
DIM='\033[2m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

# Header: Topp = lys + bold
MUTED='\033[38;2;128;128;128m'     # #808080
# Header: Bunn = dempet grå
BRIGHT='\033[38;2;238;238;238m'    # #eeeeee

echo ""
printf "  ${BRIGHT}${BOLD}█▀▀█ █▀▀█ █▀▀█ █▀▀▄ █▀▀█ ▀▀█▀▀ █▀▀▀ █▀▀█${RESET}\n"
printf "  ${MUTED}█  █ █▀▀▀ █▀▀▀ █  █ █▀▀█   █   █▀▀▀ █▀█▀${RESET}\n"
printf "  ${MUTED}▀▀▀▀ ▀    ▀    ▀▀▀  ▀  ▀   ▀   ▀▀▀▀ ▀  ▀${RESET}\n"
printf "                 ${DIM}DOTFILES${RESET}\n"
echo ""

# --------------------------------------------------------------------------
# Hjelpefunksjoner
# --------------------------------------------------------------------------

info() {
  echo ""
  echo -e "${BOLD}${BLUE}▸ ${RESET}${BOLD}$1${RESET}"
}

warn() {
  echo -e "    ${BOLD}${YELLOW}ADVARSEL:${RESET} $1"
}

success() {
  echo -e "    ${GREEN}✓${RESET}  $1"
}

_has_uncommitted_changes() {
  ! git -C "$DOTFILES_DIR" diff --quiet 2>/dev/null || \
  ! git -C "$DOTFILES_DIR" diff --cached --quiet 2>/dev/null
}

# --------------------------------------------------------------------------
# Sjekk ucommitede endringer før vi starter
# --------------------------------------------------------------------------

if _has_uncommitted_changes; then
  warn "Det finnes ucommitede endringer i $DOTFILES_DIR:"
  echo ""
  git -C "$DOTFILES_DIR" status --short | sed 's/^/      /'
  echo ""
  printf "    Vil du fortsette likevel? [y/N] "
  read -r answer
  if [[ ! "$answer" =~ ^[Yy]$ ]]; then
    echo "    Avbryter."
    exit 0
  fi
fi

# --------------------------------------------------------------------------
# Homebrew
# --------------------------------------------------------------------------

info "Oppdaterer Homebrew..."
brew update

info "Oppgraderer formulae..."
if ! brew upgrade --formula --yes; then
  warn "Noen formulae feilet under oppgradering (se over for detaljer)"
fi

info "Oppgraderer casks..."
$PRIVILEGES_CLI --add --reason "Homebrew cask upgrade"
sudo -v

# Hold sudo-sesjonen aktiv i bakgrunnen
while true; do sudo -n true; sleep 50; kill -0 "$$" || exit; done 2>/dev/null &
SUDO_KEEPALIVE_PID=$!

# Oppryddingsfunksjon for privilegier og sudo
_cleanup_privileges() {
  kill "$SUDO_KEEPALIVE_PID" 2>/dev/null
  command sudo -k 2>/dev/null
  $PRIVILEGES_CLI --remove
  trap - EXIT INT TERM
}

# Sørg for opprydding uansett hva som skjer (Ctrl+C, kill, feil, etc.)
trap '_cleanup_privileges' EXIT INT TERM

# Casks som oppdaterer seg selv ekskluderes fra brew upgrade
_excluded_casks=()
while IFS= read -r line; do
  cask=$(echo "$line" | sed -n 's/^cask "\([^"]*\)".*/\1/p')
  [[ -n "$cask" ]] && _excluded_casks+=("$cask")
done < <(grep '\[self-updates\]' "$DOTFILES_DIR/Brewfile")

# Ekskluder terminalen vi kjører fra (unngå å drepe vår egen prosess)
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
    warn "Noen casks feilet under oppgradering (se over for detaljer)"
  fi
else
  echo "    Fant ingen casks å oppgradere."
fi

if $_skipped_terminal; then
  warn "Hoppet over $_current_terminal_cask (kjørende terminal). Oppgrader manuelt: brew upgrade --cask $_current_terminal_cask"
fi

# Rydd opp og fjern trap
_cleanup_privileges

info "Rydder gamle versjoner..."
brew cleanup --prune=30

# --------------------------------------------------------------------------
# Git submoduler
# --------------------------------------------------------------------------

info "Oppdaterer git submoduler..."
git -C "$DOTFILES_DIR" submodule update --remote
success "Submoduler oppdatert."

# --------------------------------------------------------------------------
# tealdeer (tldr-sider)
# --------------------------------------------------------------------------

info "Oppdaterer tldr-sider..."
tldr --update || true
success "tldr-sider oppdatert."

# --------------------------------------------------------------------------
# jenv rehash
# --------------------------------------------------------------------------

info "Kjører jenv rehash..."
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)" 2>/dev/null
jenv rehash
success "jenv shims oppdatert."

# --------------------------------------------------------------------------
# Agent skills
# --------------------------------------------------------------------------

info "Oppdaterer agent skills..."
if command -v npx &>/dev/null; then
  npx skills update -g -y || warn "Kunne ikke oppdatere agent skills"
else
  warn "npx ikke tilgjengelig, hopper over agent skills"
fi

# --------------------------------------------------------------------------
# Sjekk for endringer som bør committes
# --------------------------------------------------------------------------

info "Sjekker for endringer i dotfiles..."

if ! _has_uncommitted_changes; then
  success "Ingen endringer å committe."
else
  echo ""
  warn "Oppdateringen har produsert endringer som bør committes:"
  echo ""
  git -C "$DOTFILES_DIR" diff --name-only | sed 's/^/      /'
  git -C "$DOTFILES_DIR" diff --cached --name-only | sed 's/^/      /'
  echo ""
fi

# --------------------------------------------------------------------------
# Ferdig
# --------------------------------------------------------------------------

echo ""
echo -e "${BOLD}${GREEN}==============================${RESET}"
echo -e "${BOLD}${GREEN}  Oppdatering ferdig!${RESET}"
echo -e "${BOLD}${GREEN}==============================${RESET}"
echo ""
