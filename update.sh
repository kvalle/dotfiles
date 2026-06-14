#!/bin/bash

DOTFILES_DIR=~/dotfiles
PRIVILEGES_CLI=$(which PrivilegesCLI 2>/dev/null) || \
  PRIVILEGES_CLI="/Applications/Privileges.app/Contents/MacOS/PrivilegesCLI"

# --------------------------------------------------------------------------
# Farger og formatering
# --------------------------------------------------------------------------

BOLD='\033[1m'
DIM='\033[2m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RESET='\033[0m'

# --------------------------------------------------------------------------
# Header
# --------------------------------------------------------------------------

echo ""
printf "${BOLD}${CYAN}"
cat << 'EOF'
  ___  ___ ___ ___   _ _____ ___ ___ ___ ___
 / _ \| _ \ _ \   \ /_\_   _| __| _ \ __| _ \
| (_) |  _/  _/ |) / _ \| | | _||   / _||   /
 \___/|_| |_| |___/_/ \_\_| |___|_|_\___|_|_\

                   DOTFILES
EOF
printf "${RESET}"
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

# --------------------------------------------------------------------------
# Sjekk ucommitede endringer før vi starter
# --------------------------------------------------------------------------

if ! git -C "$DOTFILES_DIR" diff --quiet 2>/dev/null || \
   ! git -C "$DOTFILES_DIR" diff --cached --quiet 2>/dev/null; then
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
brew upgrade --formula --yes || true

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

brew upgrade --cask --yes || true

# Rydd opp og fjern trap
_cleanup_privileges

info "Rydder gamle versjoner..."
brew cleanup

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
# Sjekk for endringer som bør committes
# --------------------------------------------------------------------------

info "Sjekker for endringer i dotfiles..."

if git -C "$DOTFILES_DIR" diff --quiet 2>/dev/null && \
   git -C "$DOTFILES_DIR" diff --cached --quiet 2>/dev/null; then
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
