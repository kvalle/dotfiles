#!/bin/sh
set -e

echo "Installing agent skills..."

if ! command -v npx >/dev/null 2>&1; then
  echo "  npx not available, skipping"
  exit 0
fi

mkdir -p ~/.agents/skills ~/.claude/skills

LOCK="$HOME/dotfiles/ai/.skill-lock.json"

if [ -f "$LOCK" ] && [ "$(jq '.skills | length' "$LOCK" 2>/dev/null)" -gt 0 ]; then
  jq -r '.skills | to_entries[] | "\(.value.source) \(.key)"' "$LOCK" \
    | sort -k1,1 \
    | awk '{skills[$1] = skills[$1] " --skill " $2} END {for (s in skills) print s, skills[s]}' \
    | while read -r source skill_args; do
        echo "  Installing from $source:$skill_args"
        eval npx skills add "$source" $skill_args --copy -g -y
      done
else
  echo "  No skills in lock file, skipping"
fi

echo "Done installing agent skills"
