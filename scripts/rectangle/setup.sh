#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"

target_dir="$HOME/Library/Application Support/Rectangle"

dotfiles_info "Installing the Rectangle configuration..."
mkdir -p "$target_dir"
cp "$DOTFILES/rectangle/RectangleConfig.json" "$target_dir/RectangleConfig.json"
dotfiles_success "Rectangle configuration is ready for import on next launch."
