#!/bin/bash

set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/dotfiles}"
MANIFEST="${SKILLS_MANIFEST_FILE:-$DOTFILES/ai/skills.txt}"

if [ -n "${SKILLS_LOCK_FILE:-}" ]; then
  LOCK_FILE="$SKILLS_LOCK_FILE"
elif [ -n "${XDG_STATE_HOME:-}" ]; then
  LOCK_FILE="$XDG_STATE_HOME/skills/.skill-lock.json"
else
  LOCK_FILE="$HOME/.agents/.skill-lock.json"
fi

usage() {
  echo "Usage: ${0##*/} --write|--check"
}

generate_manifest() {
  if [ ! -f "$LOCK_FILE" ]; then
    echo "Skill-lockfil mangler: $LOCK_FILE" >&2
    return 1
  fi

  if ! jq -e '.version and (.skills | type == "object")' "$LOCK_FILE" >/dev/null 2>&1; then
    echo "Ugyldig skill-lockfil: $LOCK_FILE" >&2
    return 1
  fi

  cat <<'EOF'
# Agent skills - generert fra ~/.agents/.skill-lock.json
# Ikke rediger manuelt. Kjor scripts/skills-manifest.sh --write.
# Format: kilde<TAB>skill

EOF

  jq -r '
    .skills
    | to_entries[]
    | [
        (if .value.sourceType == "github"
         then .value.source
         else (.value.sourceUrl // .value.source)
         end),
        .key
      ]
    | @tsv
  ' "$LOCK_FILE" | LC_ALL=C sort -t $'\t' -k1,1 -k2,2
}

case "${1:-}" in
  --write)
    tmp=$(mktemp "${TMPDIR:-/tmp}/skills-manifest.XXXXXX")
    trap 'rm -f "$tmp"' EXIT
    generate_manifest > "$tmp"
    chmod 644 "$tmp"
    mv "$tmp" "$MANIFEST"
    trap - EXIT
    echo "Oppdaterte $MANIFEST"
    ;;
  --check)
    tmp=$(mktemp "${TMPDIR:-/tmp}/skills-manifest.XXXXXX")
    trap 'rm -f "$tmp"' EXIT
    generate_manifest > "$tmp"
    if ! diff -u "$MANIFEST" "$tmp"; then
      echo "Manifestet er utdatert. Kjor scripts/skills-manifest.sh --write." >&2
      exit 1
    fi
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac
