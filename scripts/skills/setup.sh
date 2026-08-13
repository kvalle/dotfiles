#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"

dotfiles_info "Installing agent skills..."

# npx comes from fnm, so this runs after nix/setup.sh in scripts/setup.sh.
dotfiles_use_node || dotfiles_warn "fnm not available, trying the node already on PATH"

if ! command -v npx >/dev/null 2>&1; then
  dotfiles_warn "npx not available, skipping"
  exit 0
fi

mkdir -p ~/.agents/skills ~/.claude/skills

SKILLS_FILE="$DOTFILES/ai/skills.txt"

if [ ! -f "$SKILLS_FILE" ]; then
  dotfiles_warn "$SKILLS_FILE not found, skipping"
  exit 0
fi

while IFS= read -r source; do
  skills=()
  while IFS=$'\t' read -r manifest_source skill; do
    if [ "$manifest_source" = "$source" ]; then
      skills+=("$skill")
    fi
  done < <(grep -v '^#' "$SKILLS_FILE" | grep -v '^$')
  dotfiles_info "Installing ${#skills[@]} skill(s) from $source..."
  NPM_CONFIG_CACHE="${TMPDIR:-/tmp}/npm-cache" \
    npx --yes skills add "$source" --skill "${skills[@]}" --copy -g -y
done < <(
  awk -F '\t' '!/^#/ && NF == 2 { print $1 }' "$SKILLS_FILE" | LC_ALL=C sort -u
)

dotfiles_success "Agent skills installed."
