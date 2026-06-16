#!/bin/bash
set -e

cd "$(dirname "$0")"

git -C ~/dotfiles submodule init && git -C ~/dotfiles submodule update

setup/homebrew.sh
setup/nvm.sh
setup/fzf.sh
setup/macos.sh
setup/symlinks.sh
setup/secrets.sh
