#!/bin/sh
set -e

repo_root="$(cd "$(dirname "$0")/../.." && pwd)"
target_dir="$HOME/Library/Application Support/Rectangle"

mkdir -p "$target_dir"
cp "$repo_root/rectangle/RectangleConfig.json" "$target_dir/RectangleConfig.json"

echo "Rectangle configuration is ready for import on next launch"
