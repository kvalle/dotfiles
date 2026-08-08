#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/lib/common.sh"

# --------------------------------------------------------------------------
# Header-formatering
# --------------------------------------------------------------------------

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
_has_uncommitted_changes() {
  ! git -C "$DOTFILES" diff --quiet 2>/dev/null || \
  ! git -C "$DOTFILES" diff --cached --quiet 2>/dev/null
}

# --------------------------------------------------------------------------
# Sjekk ucommitede endringer før vi starter
# --------------------------------------------------------------------------

if _has_uncommitted_changes; then
  dotfiles_warn "Det finnes ucommitede endringer i $DOTFILES:"
  echo ""
  git -C "$DOTFILES" status --short | sed 's/^/      /'
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

"$SCRIPT_DIR/brew/update.sh" || exit $?

# --------------------------------------------------------------------------
# Nix
# --------------------------------------------------------------------------

dotfiles_info "Oppdaterer Nix-pakker..."
"$SCRIPT_DIR/nix/update.sh" || true

# --------------------------------------------------------------------------
# Git submoduler
# --------------------------------------------------------------------------

dotfiles_info "Oppdaterer git submoduler..."
git -C "$DOTFILES" submodule update --remote
dotfiles_success "Submoduler oppdatert."

# --------------------------------------------------------------------------
# tealdeer (tldr-sider)
# --------------------------------------------------------------------------

dotfiles_info "Oppdaterer tldr-sider..."
if tldr --update; then
  dotfiles_success "tldr-sider oppdatert."
else
  dotfiles_warn "Kunne ikke oppdatere tldr-sider"
fi

# --------------------------------------------------------------------------
# jenv rehash
# --------------------------------------------------------------------------

dotfiles_info "Kjører jenv rehash..."
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)" 2>/dev/null
jenv rehash
dotfiles_success "jenv shims oppdatert."

# --------------------------------------------------------------------------
# Agent skills
# --------------------------------------------------------------------------

dotfiles_info "Oppdaterer agent skills..."
"$SCRIPT_DIR/skills/update.sh" || true

# --------------------------------------------------------------------------
# Sjekk for endringer som bør committes
# --------------------------------------------------------------------------

dotfiles_info "Sjekker for endringer i dotfiles..."

if ! _has_uncommitted_changes; then
  dotfiles_success "Ingen endringer å committe."
else
  echo ""
  dotfiles_warn "Oppdateringen har produsert endringer som bør committes:"
  echo ""
  git -C "$DOTFILES" diff --name-only | sed 's/^/      /'
  git -C "$DOTFILES" diff --cached --name-only | sed 's/^/      /'
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
