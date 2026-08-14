#!/bin/bash

set -uo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/lib/common.sh"

dotfiles_banner "updating"

# Every step reports here instead of aborting: an update that cannot reach
# Homebrew should still refresh the skills. The collected statuses form the
# authoritative summary and decide the exit code.
ok=()
skipped=()
warnings=()
failed=()

# --------------------------------------------------------------------------
_git_status() {
  git -C "$DOTFILES" status --porcelain
}

_run_update() {
  local name=$1
  shift

  "$@"
  local status=$?
  case $status in
    0) ok+=("$name") ;;
    "$DOTFILES_EXIT_SKIPPED") skipped+=("$name") ;;
    "$DOTFILES_EXIT_WARNING") warnings+=("$name") ;;
    *) failed+=("$name") ;;
  esac
}

# --------------------------------------------------------------------------
# Check for uncommitted changes before starting
# --------------------------------------------------------------------------

if ! git_status=$(_git_status); then
  dotfiles_die "Could not read the dotfiles Git status."
fi
if [[ -n "$git_status" ]]; then
  dotfiles_warn "There are uncommitted changes in $DOTFILES:"
  echo ""
  sed 's/^/      /' <<< "$git_status"
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

_run_update "brew" "$SCRIPT_DIR/brew/update.sh"

# --------------------------------------------------------------------------
# Nix
# --------------------------------------------------------------------------

dotfiles_info "Updating Nix packages..."
_run_update "nix" "$SCRIPT_DIR/nix/update.sh"

# --------------------------------------------------------------------------
# Git submodules
# --------------------------------------------------------------------------

dotfiles_info "Updating git submodules..."
if git -C "$DOTFILES" submodule update --remote; then
  dotfiles_success "Submodules updated."
  ok+=("submodules")
else
  failed+=("submodules")
fi

# --------------------------------------------------------------------------
# tealdeer (tldr pages)
# --------------------------------------------------------------------------

dotfiles_info "Updating tldr pages..."
if ! command -v tldr >/dev/null 2>&1; then
  dotfiles_warn "tldr is not installed, skipping"
  skipped+=("tldr")
elif tldr --update; then
  dotfiles_success "tldr pages updated."
  ok+=("tldr")
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
  skipped+=("jenv")
else
  # jenv init writes shell code meant for an interactive rc file; its noise is
  # not interesting here, but a rehash that fails is. `set -u` covers this
  # script, not what jenv generates — something in it reads an unset variable,
  # which under -u would end the whole run.
  if jenv_init=$(jenv init - 2>/dev/null); then
    set +u
    eval "$jenv_init" 2>/dev/null
    init_status=$?
    set -u
  else
    init_status=$?
  fi

  if (( init_status != 0 )); then
    dotfiles_warn "jenv init failed"
    failed+=("jenv")
  elif jenv rehash; then
    dotfiles_success "jenv shims updated."
    ok+=("jenv")
  else
    failed+=("jenv")
  fi
fi

# --------------------------------------------------------------------------
# Agent skills
# --------------------------------------------------------------------------

dotfiles_info "Updating agent skills..."
_run_update "skills" "$SCRIPT_DIR/skills/update.sh"

# --------------------------------------------------------------------------
# Verify the resulting machine state
# --------------------------------------------------------------------------

_run_update "verification" "$SCRIPT_DIR/verify.sh"

# --------------------------------------------------------------------------
# Check for changes that should be committed
# --------------------------------------------------------------------------

dotfiles_info "Checking for changes in dotfiles..."

if git_status=$(_git_status); then
  git_status_ok=true
else
  git_status_ok=false
  dotfiles_warn "Could not read the dotfiles Git status."
  failed+=("git status")
fi

if $git_status_ok; then
  if [[ -z "$git_status" ]]; then
    dotfiles_success "No changes to commit."
  else
    echo ""
    dotfiles_warn "There are changes in dotfiles that should be committed:"
    echo ""
    sed 's/^/      /' <<< "$git_status"
    echo ""
  fi
fi

# --------------------------------------------------------------------------
# Done
# --------------------------------------------------------------------------

echo ""
if (( ${#failed[@]} == 0 )); then
  if (( ${#warnings[@]} == 0 )); then
    printf '%bUpdate complete.%b\n' "${GREEN}${BOLD}" "$RESET"
  else
    printf '%bUpdate complete with warnings.%b\n' "${YELLOW}${BOLD}" "$RESET"
  fi
else
  printf '%bUpdate complete with errors.%b\n' "${RED}${BOLD}" "$RESET"
fi
(( ${#ok[@]} == 0 )) || printf '  OK: %s\n' "${ok[*]}"
(( ${#skipped[@]} == 0 )) || printf '  SKIPPED: %s\n' "${skipped[*]}"
(( ${#warnings[@]} == 0 )) || printf '  WARNING: %s\n' "${warnings[*]}"
(( ${#failed[@]} == 0 )) || printf '  FAILED: %s\n' "${failed[*]}"
echo ""

(( ${#failed[@]} == 0 )) || exit 1
