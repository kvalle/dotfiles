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
Bruk: ${0##*/} [--prune]

Oppretter symlinkene som er deklarert i symlinks.conf.

  --prune     Se etter symlinker som symlinks.conf tidligere hadde ansvar
              for, men som ikke står der lenger, og tilby å fjerne dem.
  -h, --help  Vis denne hjelpeteksten.
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --prune) PRUNE=1 ;;
        -h|--help) usage; exit 0 ;;
        *) dotfiles_die "Ukjent argument: $1" ;;
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

prune_orphans() {
    local orphans dest target

    if ! git_history_available; then
        dotfiles_warn "Kan ikke se etter foreldreløse symlinker uten git-historikken."
        return 0
    fi

    orphans=$(orphan_symlinks)
    if [[ -z "$orphans" ]]; then
        printf "  %b-%b Ingen foreldreløse symlinker\n" "$DIM" "$RESET"
        return 0
    fi

    if ! dotfiles_tty_available; then
        dotfiles_warn "Kan ikke spørre om fjerning uten en interaktiv terminal."
    fi

    while IFS=$'\t' read -r dest target; do
        dotfiles_warn "$dest -> $target står ikke i symlinks.conf"
        if dotfiles_confirm "Fjerne symlinken?"; then
            rm -f "$dest"
            printf "  %b✓%b Fjernet: %s\n" "$GREEN" "$RESET" "$dest"
            PRUNED=$((PRUNED + 1))
        else
            printf "  %b-%b Beholdt: %s\n" "$DIM" "$RESET" "$dest"
        fi
    done <<< "$orphans"
}

while read -r type src dest; do
    src="$DOTFILES/$src"
    dest=$(expand_destination "$dest") || dotfiles_die "Ugyldig relativ målsti i symlinks.conf: $dest"
    [[ "$type" == f || "$type" == d ]] || dotfiles_die "Ukjent symlinktype: $type"
    link_config "$src" "$dest"
done < <(conf_entries)

# Spesialtilfelle: Zen Browser (dynamisk profilsti)
ZEN_PROFILE=$(find "$HOME/Library/Application Support/zen/Profiles" \
    -maxdepth 1 -name "*.Default (release)" -type d 2>/dev/null | head -1 || true)
if [ -n "$ZEN_PROFILE" ]; then
    link_config "$DOTFILES/zen/user.js" "$ZEN_PROFILE/user.js"
else
    echo "  Zen Browser: profil ikke funnet, hopper over"
fi

if (( PRUNE )); then
    echo
    echo "Rydder symlinker som ikke lenger står i symlinks.conf"
    prune_orphans
    printf "\n%d symlinks opprettet, %d skippet (allerede korrekte), %d fjernet, %d feilet.\n" \
        "$CREATED" "$SKIPPED" "$PRUNED" "$FAILED"
else
    printf "\n%d symlinks opprettet, %d skippet (allerede korrekte), %d feilet.\n" \
        "$CREATED" "$SKIPPED" "$FAILED"
fi

(( FAILED == 0 ))
