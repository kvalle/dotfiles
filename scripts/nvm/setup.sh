#!/bin/bash
set -e

echo "Starting installing NVM"

if ! [[ -d ~/.nvm ]]; then
  # Install latest version of nvm
  # Check https://github.com/nvm-sh/nvm/releases for available versions
  NVM_VERSION=$(curl -s https://api.github.com/repos/nvm-sh/nvm/releases/latest | grep '"tag_name"' | sed 's/.*"v\(.*\)".*/\1/')
  curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh" | bash
fi

echo "Done installing NVM"
