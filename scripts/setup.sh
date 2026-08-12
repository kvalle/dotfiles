#!/bin/bash
set -e

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/lib/common.sh"
cd "$SCRIPT_DIR"

dotfiles_banner "setting up"

git -C "$DOTFILES" submodule init && git -C "$DOTFILES" submodule update

brew/setup.sh
nix/setup.sh
source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
export PATH="$DOTFILES_NIX_PROFILE/bin:$PATH"
rectangle/setup.sh
macos/setup.sh
symlinks/setup.sh
bat/setup.sh
skills/setup.sh
secrets/setup.sh

# Verify that everything is set up correctly
./verify.sh
