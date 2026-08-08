#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"

if ! command -v nix >/dev/null 2>&1; then
  PRIVILEGES_CLI=$(command -v PrivilegesCLI 2>/dev/null) || \
    PRIVILEGES_CLI="/Applications/Privileges.app/Contents/MacOS/PrivilegesCLI"

  if [[ ! -x "$PRIVILEGES_CLI" ]]; then
    echo "PrivilegesCLI ikke funnet. Kan ikke installere Nix." >&2
    exit 1
  fi

  "$PRIVILEGES_CLI" --add --reason "Install Determinate Nix"
  trap '"$PRIVILEGES_CLI" --remove' EXIT INT TERM

  echo "Installing Determinate Nix"
  curl --proto '=https' --tlsv1.2 -fsSL https://install.determinate.systems/nix | \
    sh -s -- install

  "$PRIVILEGES_CLI" --remove
  trap - EXIT INT TERM

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
