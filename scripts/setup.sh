#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/lib/common.sh"
cd "$SCRIPT_DIR"

dotfiles_banner "setting up"

git -C "$DOTFILES" submodule init && git -C "$DOTFILES" submodule update

brew/setup.sh
nix/setup.sh

# Puts the `nix` command on PATH.
NIX_DAEMON_SCRIPT=/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
if [[ -f "$NIX_DAEMON_SCRIPT" ]]; then
  source "$NIX_DAEMON_SCRIPT"
else
  dotfiles_warn "Nix profile script not found: $NIX_DAEMON_SCRIPT"
  dotfiles_warn "The nix command will not be on PATH - verify.sh will report it."
fi

export PATH="$DOTFILES_NIX_PROFILE/bin:$PATH"
rectangle/setup.sh
macos/setup.sh
symlinks/setup.sh
bat/setup.sh
skills/setup.sh
secrets/setup.sh

# Verify that everything is set up correctly
./verify.sh
