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
  grep -v '^\s*#' "$DOTFILES/symlinks.conf" | grep -v '^\s*$'
}

git_history_available() {
  git -C "$DOTFILES" rev-parse --git-dir >/dev/null 2>&1
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
