#!/bin/bash
set -e

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/lib/common.sh"
cd "$SCRIPT_DIR"

git -C "$DOTFILES" submodule init && git -C "$DOTFILES" submodule update

setup/homebrew.sh
setup/nix.sh
source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
export PATH="$HOME/.local/state/nix/profiles/dotfiles/bin:$PATH"
setup/rectangle.sh
setup/nvm.sh
setup/fzf.sh
setup/macos.sh
setup/symlinks.sh
setup/bat.sh
setup/skills.sh
setup/secrets.sh

# Verifiser at alt er korrekt satt opp
./verify.sh
