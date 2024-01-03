#!/bin/bash
set -e

git submodule init
git submodule update

setup/homebrew.sh
setup/omz.sh
setup/nvm.sh
setup/fzf.sh
setup/macos.sh
setup/symlinks.sh
