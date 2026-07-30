#!/bin/bash
set -euo pipefail

echo "Installing agent skills..."

if ! command -v npx >/dev/null 2>&1; then
  echo "  npx not available, skipping"
  exit 0
fi

mkdir -p ~/.agents/skills ~/.claude/skills

SKILLS_FILE="$HOME/dotfiles/ai/skills.txt"

if [ ! -f "$SKILLS_FILE" ]; then
  echo "  $SKILLS_FILE not found, skipping"
  exit 0
fi

while IFS= read -r source; do
  skills=()
  while IFS=$'\t' read -r manifest_source skill; do
    if [ "$manifest_source" = "$source" ]; then
      skills+=("$skill")
    fi
  done < <(grep -v '^#' "$SKILLS_FILE" | grep -v '^$')
  echo "  Installing ${#skills[@]} skill(s) from $source"
  npx skills add "$source" --skill "${skills[@]}" --copy -g -y
done < <(
  awk -F '\t' '!/^#/ && NF == 2 { print $1 }' "$SKILLS_FILE" | LC_ALL=C sort -u
)

echo "Done installing agent skills"
