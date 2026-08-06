#!/bin/bash
set -e

echo "Starting configuring fzf"

if command -v fzf >/dev/null; then
  echo "fzf uses its built-in zsh integration"
else
  echo "fzf not installed, please install it first"
fi

echo "Done configuring fzf"
