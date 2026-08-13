#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"

dotfiles_info "Building the bat theme cache..."
bat cache --build
dotfiles_success "bat cache built."
