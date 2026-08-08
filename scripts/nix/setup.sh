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

  dotfiles_privileges_cleanup || dotfiles_die "Midlertidige adminrettigheter ble ikke fjernet."

  if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
    # Gjør Nix tilgjengelig uten å kreve en ny terminal.
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  fi
fi

if ! command -v nix >/dev/null 2>&1; then
  echo "Nix ble installert, men finnes ikke i PATH. Åpne en ny terminal og kjør scriptet på nytt." >&2
  exit 1
fi

"$SCRIPT_DIR/apply.sh"
