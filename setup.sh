#!/bin/bash
set -e

cd "$(dirname "$0")"

git submodule init && git submodule update

setup/homebrew.sh
setup/nvm.sh
setup/fzf.sh
setup/macos.sh
setup/symlinks.sh
setup/secrets.sh
