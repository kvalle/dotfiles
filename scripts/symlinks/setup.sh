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

usage() {
    cat <<EOF
Usage: ${0##*/} [--prune]

Creates the symlinks declared in symlinks.conf.

  --prune     Look for symlinks that symlinks.conf used to be responsible
              for but no longer declares, and offer to remove them.
  -h, --help  Show this help text.
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --prune) PRUNE=1 ;;
        -h|--help) usage; exit 0 ;;
        *) dotfiles_die "Unknown argument: $1" ;;
    esac
    shift
done

echo "Setting up symlinks"

confirm_overwrite() {
    local dest=$1 prompt=$2
    local status=0

    dotfiles_confirm "$prompt" && return 0
    status=$?

    if (( status == 2 )); then
        dotfiles_warn "Cannot ask about overwriting without an interactive terminal."
    fi

    dotfiles_warn "Kept $dest unchanged"
    FAILED=$((FAILED + 1))
    return 1
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
            dotfiles_warn "$dest points to $actual, expected $src"
            confirm_overwrite "$dest" "Overwrite the symlink?" || return 0
        fi
        rm -f "$dest"
    elif [[ -e "$dest" ]]; then
        dotfiles_warn "$dest is an existing file or directory"
        confirm_overwrite "$dest" "Overwrite existing content?" || return 0
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
        if dotfiles_confirm "Remove the symlink?"; then
            rm -f "$dest"
            printf "  %b✓%b Removed: %s\n" "$GREEN" "$RESET" "$dest"
            PRUNED=$((PRUNED + 1))
        else
            printf "  %b-%b Kept: %s\n" "$DIM" "$RESET" "$dest"
        fi
    done <<< "$orphans"
}

while read -r type src dest; do
    src="$DOTFILES/$src"
    dest=$(expand_destination "$dest") || dotfiles_die "Invalid relative destination path in symlinks.conf: $dest"
    [[ "$type" == f || "$type" == d ]] || dotfiles_die "Unknown symlink type: $type"
    link_config "$src" "$dest"
done < <(conf_entries)

# Special case: Zen Browser (dynamic profile path, see zen_profile in common.sh)
if ZEN_PROFILE=$(zen_profile); then
    link_config "$DOTFILES/zen/user.js" "$ZEN_PROFILE/user.js"
else
    dotfiles_warn "Zen Browser: profile not found, skipping"
fi

if (( PRUNE )); then
    echo
    echo "Pruning symlinks that symlinks.conf no longer declares"
    prune_orphans
    printf "\n%d symlinks created, %d skipped (already correct), %d removed, %d failed.\n" \
        "$CREATED" "$SKIPPED" "$PRUNED" "$FAILED"
else
    printf "\n%d symlinks created, %d skipped (already correct), %d failed.\n" \
        "$CREATED" "$SKIPPED" "$FAILED"
fi

(( FAILED == 0 ))
