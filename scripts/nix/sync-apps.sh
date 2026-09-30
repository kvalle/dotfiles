#!/bin/bash

# Copy the .app bundles from the dotfiles Nix profile into ~/Applications/Nix
# Apps so that Spotlight and launchers built on it (such as Tuna) find them.
# Spotlight ignores symlinks and Finder aliases, so the bundles must be real
# copies. Each copy has a sidecar file recording the store path it came from
# (kept outside the bundle so the code signature stays intact) and is only
# replaced when that path changes. Bundles no longer in the profile are removed.

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"

SOURCE_DIR="$DOTFILES_NIX_PROFILE/Applications"
TARGET_DIR="$HOME/Applications/Nix Apps"

marker_for() {
  printf '%s/.%s.store-path' "$TARGET_DIR" "$1"
}

mkdir -p "$TARGET_DIR"

wanted=" "
if [[ -d "$SOURCE_DIR" ]]; then
  for app in "$SOURCE_DIR"/*.app; do
    [[ -e "$app" ]] || continue
    name=$(basename "$app")
    wanted+="$name "
    store_path=$(readlink -f "$app")
    target="$TARGET_DIR/$name"
    marker=$(marker_for "$name")

    if [[ -d "$target" && -f "$marker" && "$(cat "$marker")" == "$store_path" ]]; then
      continue
    fi

    rm -rf "$target"
    cp -RL "$store_path" "$target"
    chmod -R u+w "$target"
    printf '%s\n' "$store_path" > "$marker"
    echo "Copied $name to $TARGET_DIR"
  done
fi

# Remove bundles this script created that are no longer in the profile.
for marker in "$TARGET_DIR"/.*.app.store-path; do
  [[ -f "$marker" ]] || continue
  name=$(basename "$marker")
  name=${name#.}
  name=${name%.store-path}
  if [[ "$wanted" != *" $name "* ]]; then
    rm -rf "${TARGET_DIR:?}/$name" "$marker"
    echo "Removed $name from $TARGET_DIR"
  fi
done
