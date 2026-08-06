#!/bin/bash
set -e

cd "$(dirname "$0")"

git -C ~/dotfiles submodule init && git -C ~/dotfiles submodule update

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
