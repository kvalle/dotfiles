#!/bin/sh
set -e

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

# Bruk filedeskriptor for å unngå å konsumere stdin i while-loopen
while read -r source; do
  echo "  Installing from $source"
  npx skills add "$source" --copy -g </dev/tty
done <<EOF
$(grep -v '^\s*#' "$SKILLS_FILE" | grep -v '^\s*$')
EOF

echo "Done installing agent skills"
