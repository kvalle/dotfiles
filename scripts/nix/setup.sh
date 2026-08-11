#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/privileges.sh"

if ! command -v nix >/dev/null 2>&1; then
  dotfiles_privileges_begin "Install Determinate Nix"

  echo "Installing Determinate Nix"
  curl --proto '=https' --tlsv1.2 -fsSL https://install.determinate.systems/nix | \
    sh -s -- install

  dotfiles_privileges_cleanup || dotfiles_die "Temporary admin privileges were not revoked."

  if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
    # Make Nix available without requiring a new terminal.
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  fi
fi

if ! command -v nix >/dev/null 2>&1; then
  echo "Nix was installed but is not on PATH. Open a new terminal and run the script again." >&2
  exit 1
fi

"$SCRIPT_DIR/apply.sh"
