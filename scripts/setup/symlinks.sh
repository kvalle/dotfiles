#!/bin/sh
set -e

DOTFILES="$HOME/dotfiles"
CONF="$DOTFILES/symlinks.conf"

echo "Setting up symlinks"

# Les symlinks.conf og opprett lenker
grep -v '^\s*#' "$CONF" | grep -v '^\s*$' | while read -r type src dest; do
    src="$DOTFILES/$src"
    dest=$(eval echo "$dest")
    mkdir -p "$(dirname "$dest")"
    if [ "$type" = "d" ]; then
        rm -rf "$dest"
    else
        rm -f "$dest"
    fi
    ln -s "$src" "$dest"
    echo "  $dest -> $src"
done

# Spesialtilfelle: Zen Browser (dynamisk profilsti)
ZEN_PROFILE=$(find "$HOME/Library/Application Support/zen/Profiles" \
    -maxdepth 1 -name "*.Default (release)" -type d 2>/dev/null | head -1)
if [ -n "$ZEN_PROFILE" ]; then
    rm -f "$ZEN_PROFILE/user.js"
    ln -s "$DOTFILES/zen/user.js" "$ZEN_PROFILE/user.js"
    echo "  $ZEN_PROFILE/user.js -> $DOTFILES/zen/user.js"
else
    echo "  Zen Browser: profil ikke funnet, hopper over"
fi

echo "Done setting up symlinks"
