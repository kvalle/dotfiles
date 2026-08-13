#!/bin/bash

set -uo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/lib/common.sh"

dotfiles_banner "updating"

# Every step reports here instead of aborting: an update that cannot reach
# Homebrew should still refresh the skills. The names collected are what the
# summary prints and what decides the exit code. A step that is skipped because
# its tool is not installed is a warning, not a failure — the same distinction
# verify.sh draws between verify_warn and verify_fail.
failed=()

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

"$SCRIPT_DIR/brew/update.sh" || failed+=("brew")

# --------------------------------------------------------------------------
# Nix
# --------------------------------------------------------------------------

dotfiles_info "Updating Nix packages..."
"$SCRIPT_DIR/nix/update.sh" || failed+=("nix")

# --------------------------------------------------------------------------
# Git submodules
# --------------------------------------------------------------------------

dotfiles_info "Updating git submodules..."
if git -C "$DOTFILES" submodule update --remote; then
  dotfiles_success "Submodules updated."
else
  failed+=("submodules")
fi

# --------------------------------------------------------------------------
# tealdeer (tldr pages)
# --------------------------------------------------------------------------

dotfiles_info "Updating tldr pages..."
if ! command -v tldr >/dev/null 2>&1; then
  dotfiles_warn "tldr is not installed, skipping"
elif tldr --update; then
  dotfiles_success "tldr pages updated."
else
  failed+=("tldr")
fi

# --------------------------------------------------------------------------
# jenv rehash
# --------------------------------------------------------------------------

dotfiles_info "Running jenv rehash..."
export PATH="$HOME/.jenv/bin:$PATH"
if ! command -v jenv >/dev/null 2>&1; then
  dotfiles_warn "jenv is not installed, skipping"
else
  # jenv init writes shell code meant for an interactive rc file; its noise is
  # not interesting here, but a rehash that fails is. `set -u` covers this
  # script, not what jenv generates — something in it reads an unset variable,
  # which under -u would end the whole run.
  set +u
  eval "$(jenv init -)" 2>/dev/null
  set -u
  if jenv rehash; then
    dotfiles_success "jenv shims updated."
  else
    failed+=("jenv")
  fi
fi

# --------------------------------------------------------------------------
# Agent skills
# --------------------------------------------------------------------------

dotfiles_info "Updating agent skills..."
"$SCRIPT_DIR/skills/update.sh" || failed+=("skills")

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
if (( ${#failed[@]} == 0 )); then
  printf '%bUpdate complete - no problems found.%b\n\n' "${GREEN}${BOLD}" "$RESET"
else
  printf '%bUpdate failed for: %s%b\n\n' "${RED}${BOLD}" "${failed[*]}" "$RESET"
  exit 1
fi
