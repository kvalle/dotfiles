#!/bin/bash
set -e

echo "Starting installing NVM"

if ! [[ -d ~/.nvm ]]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi

echo "Done installing NVM"
