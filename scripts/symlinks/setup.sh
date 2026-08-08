#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/common.sh"

CONF="$DOTFILES/symlinks.conf"
CREATED=0
SKIPPED=0
FAILED=0

echo "Setting up symlinks"

confirm_overwrite() {
    local dest=$1 prompt=$2 answer

    if [[ -r /dev/tty && -w /dev/tty ]]; then
        printf "    %s [y/N] " "$prompt" > /dev/tty
        read -r answer < /dev/tty
        [[ "$answer" =~ ^[Yy]$ ]] && return 0
    else
        dotfiles_warn "Kan ikke spørre om overskriving uten en interaktiv terminal."
    fi

    dotfiles_warn "Beholdt $dest uendret"
    FAILED=$((FAILED + 1))
    return 1
}

link_config() {
    local src=$1 dest=$2
    local actual

    if [[ ! -e "$src" ]]; then
        dotfiles_die "Kilden finnes ikke: $src"
    fi

    if [[ -L "$dest" ]]; then
        actual=$(readlink "$dest")
        if [[ "$actual" == "$src" ]]; then
            printf "  %b-%b %s -> %s (allerede korrekt)\n" "$DIM" "$RESET" "$dest" "$src"
            SKIPPED=$((SKIPPED + 1))
            return
        fi
        if [[ ! -e "$dest" ]]; then
            dotfiles_warn "Erstatter brukket symlink: $dest -> $actual"
        else
            dotfiles_warn "$dest peker til $actual, forventet $src"
            confirm_overwrite "$dest" "Overskrive symlinken?" || return 0
        fi
        rm -f "$dest"
    elif [[ -e "$dest" ]]; then
        dotfiles_warn "$dest er en eksisterende fil eller katalog"
        confirm_overwrite "$dest" "Overskrive eksisterende innhold?" || return 0
        rm -rf "$dest"
    fi

    mkdir -p "$(dirname "$dest")"
    ln -s "$src" "$dest"
    printf "  %b✓%b Opprettet: %s -> %s\n" "$GREEN" "$RESET" "$dest" "$src"
    CREATED=$((CREATED + 1))
}

while read -r type src dest; do
    src="$DOTFILES/$src"
    dest=$(expand_destination "$dest") || dotfiles_die "Ugyldig relativ målsti i symlinks.conf: $dest"
    [[ "$type" == f || "$type" == d ]] || dotfiles_die "Ukjent symlinktype: $type"
    link_config "$src" "$dest"
done < <(grep -v '^\s*#' "$CONF" | grep -v '^\s*$')

# Spesialtilfelle: Zen Browser (dynamisk profilsti)
ZEN_PROFILE=$(find "$HOME/Library/Application Support/zen/Profiles" \
    -maxdepth 1 -name "*.Default (release)" -type d 2>/dev/null | head -1 || true)
if [ -n "$ZEN_PROFILE" ]; then
    link_config "$DOTFILES/zen/user.js" "$ZEN_PROFILE/user.js"
else
    echo "  Zen Browser: profil ikke funnet, hopper over"
fi

printf "\n%d symlinks opprettet, %d skippet (allerede korrekte), %d feilet.\n" \
    "$CREATED" "$SKIPPED" "$FAILED"

(( FAILED == 0 ))
