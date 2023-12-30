#!/bin/bash
set -e

if ! [[ -d ~/.nvm ]]; then
  echo "Installing nvm"
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi
