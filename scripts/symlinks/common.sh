#!/bin/bash

expand_destination() {
  case "$1" in
    '~') printf '%s\n' "$HOME" ;;
    '~/'*) printf '%s/%s\n' "$HOME" "${1#\~/}" ;;
    /*) printf '%s\n' "$1" ;;
    *) return 1 ;;
  esac
}

# The lines of symlinks.conf that declare a symlink.
conf_entries() {
  grep -v '^[[:space:]]*#' "$DOTFILES/symlinks.conf" | grep -v '^[[:space:]]*$'
}

path_has_dot_component() {
  case "/$1/" in
    */./*|*/../*) return 0 ;;
    *) return 1 ;;
  esac
}

# Print every manifest error and return non-zero if symlinks.conf is unsafe to
# apply. Destinations may contain spaces, so the third field is the rest of the
# line rather than a single whitespace-delimited word.
validate_conf() {
  local line_number=0 errors=0 type src dest expanded_src expanded_dest
  local seen_destinations=""

  while IFS= read -r line || [[ -n "$line" ]]; do
    line_number=$((line_number + 1))
    [[ "$line" =~ ^[[:space:]]*(#|$) ]] && continue

    type=""
    src=""
    dest=""
    read -r type src dest <<< "$line"

    if [[ -z "$type" || -z "$src" || -z "$dest" ]]; then
      printf 'symlinks.conf:%d: expected type, source and destination\n' "$line_number"
      errors=$((errors + 1))
      continue
    fi

    if [[ "$type" != f && "$type" != d ]]; then
      printf 'symlinks.conf:%d: unknown symlink type: %s\n' "$line_number" "$type"
      errors=$((errors + 1))
    fi

    if [[ "$src" == /* || "$src" == '~'* ]] || path_has_dot_component "$src"; then
      printf 'symlinks.conf:%d: source must be a safe relative path: %s\n' "$line_number" "$src"
      errors=$((errors + 1))
    else
      expanded_src="$DOTFILES/$src"
      if [[ ! -e "$expanded_src" ]]; then
        printf 'symlinks.conf:%d: source does not exist: %s\n' "$line_number" "$src"
        errors=$((errors + 1))
      elif [[ "$type" == f && ! -f "$expanded_src" ]]; then
        printf 'symlinks.conf:%d: source is not a file: %s\n' "$line_number" "$src"
        errors=$((errors + 1))
      elif [[ "$type" == d && ! -d "$expanded_src" ]]; then
        printf 'symlinks.conf:%d: source is not a directory: %s\n' "$line_number" "$src"
        errors=$((errors + 1))
      fi
    fi

    if path_has_dot_component "$dest" || ! expanded_dest=$(expand_destination "$dest"); then
      printf 'symlinks.conf:%d: destination must be an absolute path without . or .. components: %s\n' "$line_number" "$dest"
      errors=$((errors + 1))
      continue
    fi

    if [[ "$expanded_dest" != "$HOME"/* ]]; then
      printf 'symlinks.conf:%d: destination must be below HOME: %s\n' "$line_number" "$dest"
      errors=$((errors + 1))
    fi

    if printf '%s\n' "$seen_destinations" | grep -Fxq -- "$expanded_dest"; then
      printf 'symlinks.conf:%d: duplicate destination: %s\n' "$line_number" "$dest"
      errors=$((errors + 1))
    else
      seen_destinations="${seen_destinations}${seen_destinations:+$'\n'}${expanded_dest}"
    fi
  done < "$DOTFILES/symlinks.conf"

  (( errors == 0 ))
}

git_history_available() {
  git -C "$DOTFILES" rev-parse --git-dir >/dev/null 2>&1
}

# Zen Browser cannot be expressed in symlinks.conf: the profile directory is
# named per install. Setup and verify need the same search, so the pattern lives
# here as one string in one place.
#
# Prints the profile directory and returns 0 when one is found, prints nothing
# and returns 1 otherwise. `head` closing the pipe early makes `find` fail under
# `pipefail`, so that is absorbed here rather than at each call site — the two
# callers run under different error policies.
zen_profile() {
  local profile
  profile=$(find "$HOME/Library/Application Support/zen/Profiles" \
    -maxdepth 1 -name "*.Default (release)" -type d 2>/dev/null | head -1) || true
  [ -n "$profile" ] || return 1
  printf '%s\n' "$profile"
}

# Destinations the current symlinks.conf declares, expanded to absolute paths.
declared_destinations() {
  local type src dest
  while read -r type src dest; do
    expand_destination "$dest" || true
  done < <(conf_entries)
}

# Destinations symlinks.conf has ever declared and later dropped, read from the
# removed lines in its git history. Reordering and moved sources show up here
# as well, so the caller has to subtract what the config still declares.
retired_destinations() {
  git -C "$DOTFILES" log -p --follow -- symlinks.conf |
    sed -n 's/^-[[:space:]]*[fd][[:space:]]\{1,\}[^[:space:]]\{1,\}[[:space:]]\{1,\}//p' |
    sort -u
}

# Symlinks left behind by entries symlinks.conf no longer declares, printed as
# "destination<TAB>target". Derived from git history, so nothing under $HOME is
# scanned. A destination only qualifies while it is still a symlink pointing
# into $DOTFILES: real files and directories that have taken over the path are
# left alone, and so are symlinks owned by anything other than this repo. The
# prefix match holds for broken links too, which is the case that matters most.
#
# Zen Browser is not covered, since its destination is a dynamic profile path
# that never appears in symlinks.conf.
orphan_symlinks() {
  local declared dest target

  git_history_available || return 0
  declared=$(declared_destinations)

  while IFS= read -r dest; do
    dest=$(expand_destination "$dest") || continue
    printf '%s\n' "$declared" | grep -Fxq -- "$dest" && continue
    [[ -L "$dest" ]] || continue
    target=$(readlink "$dest")
    case "$target" in
      "$DOTFILES"/*) printf '%s\t%s\n' "$dest" "$target" ;;
    esac
  done < <(retired_destinations)
}
