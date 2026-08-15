#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/common.sh"

CREATED=0
SKIPPED=0
FAILED=0
PRUNE=0
PRUNED=0
FORCE=0

usage() {
    cat <<EOF
Usage: ${0##*/} [--force] [--prune]

Creates the symlinks declared in symlinks.conf.

  --force     Delete and replace conflicting content without confirmation.
  --prune     Look for symlinks that symlinks.conf used to be responsible
              for but no longer declares, and offer to remove them.
  -h, --help  Show this help text.
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --force) FORCE=1 ;;
        --prune) PRUNE=1 ;;
        -h|--help) usage; exit 0 ;;
        *) dotfiles_die "Unknown argument: $1" ;;
    esac
    shift
done

dotfiles_info "Setting up symlinks..."

if ! validation_errors=$(validate_conf); then
    while IFS= read -r error; do
        dotfiles_warn "$error"
    done <<< "$validation_errors"
    dotfiles_die "symlinks.conf is invalid; no symlinks were changed."
fi

confirm_overwrite() {
    local dest=$1 prompt=$2
    local status=0

    (( FORCE )) && return 0

    dotfiles_confirm "$prompt" && return 0
    status=$?

    if (( status == 2 )); then
        dotfiles_warn "Cannot ask about overwriting without an interactive terminal."
    fi

    dotfiles_warn "Kept $dest unchanged"
    FAILED=$((FAILED + 1))
    return 1
}

warn_existing_content() {
    local dest=$1

    if [[ -d "$dest" ]]; then
        dotfiles_warn "The directory $dest and all of its contents will be permanently deleted:"
        find "$dest" -mindepth 1 -print
    else
        dotfiles_warn "The file $dest will be permanently deleted."
    fi
}

link_config() {
    local src=$1 dest=$2
    local actual

    if [[ ! -e "$src" ]]; then
        dotfiles_die "Source does not exist: $src"
    fi

    if [[ -L "$dest" ]]; then
        actual=$(readlink "$dest")
        if [[ "$actual" == "$src" ]]; then
            printf "  %b-%b %s -> %s (already correct)\n" "$DIM" "$RESET" "$dest" "$src"
            SKIPPED=$((SKIPPED + 1))
            return
        fi
        if [[ ! -e "$dest" ]]; then
            dotfiles_warn "Replacing broken symlink: $dest -> $actual"
        else
            dotfiles_warn "$dest points to $actual, expected $src."
            confirm_overwrite "$dest" "Delete and replace this symlink?" || return 0
        fi
        rm -f "$dest"
    elif [[ -e "$dest" ]]; then
        warn_existing_content "$dest"
        confirm_overwrite "$dest" "Delete this content and replace it with a symlink?" || return 0
        rm -rf "$dest"
    fi

    mkdir -p "$(dirname "$dest")"
    ln -s "$src" "$dest"
    printf "  %b✓%b Created: %s -> %s\n" "$GREEN" "$RESET" "$dest" "$src"
    CREATED=$((CREATED + 1))
}

prune_orphans() {
    local orphans dest target

    if ! git_history_available; then
        dotfiles_warn "Cannot look for orphaned symlinks without the git history."
        return 0
    fi

    orphans=$(orphan_symlinks)
    if [[ -z "$orphans" ]]; then
        printf "  %b-%b No orphaned symlinks\n" "$DIM" "$RESET"
        return 0
    fi

    if ! dotfiles_tty_available; then
        dotfiles_warn "Cannot ask about removal without an interactive terminal."
    fi

    while IFS=$'\t' read -r dest target; do
        dotfiles_warn "$dest -> $target is not declared in symlinks.conf"
        if (( FORCE )) || dotfiles_confirm "Remove the symlink?"; then
            rm -f "$dest"
            printf "  %b✓%b Removed: %s\n" "$GREEN" "$RESET" "$dest"
            PRUNED=$((PRUNED + 1))
        else
            printf "  %b-%b Kept: %s\n" "$DIM" "$RESET" "$dest"
        fi
    done <<< "$orphans"
}

while read -r _ src dest; do
    src="$DOTFILES/$src"
    dest=$(expand_destination "$dest")
    link_config "$src" "$dest"
done < <(conf_entries)

# Special case: Zen Browser (dynamic profile path, see zen_profile in common.sh)
if ZEN_PROFILE=$(zen_profile); then
    link_config "$DOTFILES/zen/user.js" "$ZEN_PROFILE/user.js"
else
    dotfiles_warn "Zen Browser: profile not found, skipping"
fi

if (( PRUNE )); then
    dotfiles_info "Pruning symlinks that symlinks.conf no longer declares..."
    prune_orphans
    printf "\n%d symlinks created, %d skipped (already correct), %d removed, %d failed.\n" \
        "$CREATED" "$SKIPPED" "$PRUNED" "$FAILED"
else
    printf "\n%d symlinks created, %d skipped (already correct), %d failed.\n" \
        "$CREATED" "$SKIPPED" "$FAILED"
fi

(( FAILED == 0 ))
