#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/lib/common.sh"

dotfiles_banner "updating"

# --------------------------------------------------------------------------
_has_uncommitted_changes() {
  ! git -C "$DOTFILES" diff --quiet 2>/dev/null || \
  ! git -C "$DOTFILES" diff --cached --quiet 2>/dev/null
}

# --------------------------------------------------------------------------
# Check for uncommitted changes before starting
# --------------------------------------------------------------------------

if _has_uncommitted_changes; then
  dotfiles_warn "There are uncommitted changes in $DOTFILES:"
  echo ""
  git -C "$DOTFILES" status --short | sed 's/^/      /'
  echo ""
  dotfiles_confirm "Continue anyway?"
  answer_status=$?
  if (( answer_status != 0 )); then
    if (( answer_status == 2 )); then
      dotfiles_warn "Cannot ask whether to continue without an interactive terminal."
    fi
    echo "    Aborting."
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

dotfiles_info "Updating Nix packages..."
"$SCRIPT_DIR/nix/update.sh" || true

# --------------------------------------------------------------------------
# Git submodules
# --------------------------------------------------------------------------

dotfiles_info "Updating git submodules..."
git -C "$DOTFILES" submodule update --remote
dotfiles_success "Submodules updated."

# --------------------------------------------------------------------------
# tealdeer (tldr pages)
# --------------------------------------------------------------------------

dotfiles_info "Updating tldr pages..."
if tldr --update; then
  dotfiles_success "tldr pages updated."
else
  dotfiles_warn "Could not update tldr pages"
fi

# --------------------------------------------------------------------------
# jenv rehash
# --------------------------------------------------------------------------

dotfiles_info "Running jenv rehash..."
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)" 2>/dev/null
jenv rehash
dotfiles_success "jenv shims updated."

# --------------------------------------------------------------------------
# Agent skills
# --------------------------------------------------------------------------

dotfiles_info "Updating agent skills..."
"$SCRIPT_DIR/skills/update.sh" || true

# --------------------------------------------------------------------------
# Check for changes that should be committed
# --------------------------------------------------------------------------

dotfiles_info "Checking for changes in dotfiles..."

if ! _has_uncommitted_changes; then
  dotfiles_success "No changes to commit."
else
  echo ""
  dotfiles_warn "The update produced changes that should be committed:"
  echo ""
  git -C "$DOTFILES" diff --name-only | sed 's/^/      /'
  git -C "$DOTFILES" diff --cached --name-only | sed 's/^/      /'
  echo ""
fi

# --------------------------------------------------------------------------
# Done
# --------------------------------------------------------------------------

echo ""
echo -e "${BOLD}${GREEN}==============================${RESET}"
echo -e "${BOLD}${GREEN}  Update complete!${RESET}"
echo -e "${BOLD}${GREEN}==============================${RESET}"
echo ""
