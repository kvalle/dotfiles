#!/bin/bash
set -e

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/lib/common.sh"
cd "$SCRIPT_DIR"

git -C "$DOTFILES" submodule init && git -C "$DOTFILES" submodule update

brew/setup.sh
nix/setup.sh
source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
export PATH="$HOME/.local/state/nix/profiles/dotfiles/bin:$PATH"
rectangle/setup.sh
nvm/setup.sh
macos/setup.sh
symlinks/setup.sh
bat/setup.sh
skills/setup.sh
secrets/setup.sh

# Verifiser at alt er korrekt satt opp
./verify.sh
