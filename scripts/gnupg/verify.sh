#!/bin/bash

set -o pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/verify-output.sh"

CONFIG="$DOTFILES/gnupg/gpg-agent.conf"

verify_header "GnuPG"

pinentry=$(sed -n 's/^pinentry-program //p' "$CONFIG")
pinentry=${pinentry/#\~/$HOME}

if [[ -n "$pinentry" && -x "$pinentry" ]]; then
  verify_pass "pinentry-mac configured for gpg-agent"
else
  verify_fail "pinentry-mac ($pinentry missing or not executable)"
fi

verify_finish
