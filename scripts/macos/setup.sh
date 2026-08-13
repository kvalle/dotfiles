#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "$SCRIPT_DIR/../lib/common.sh"

dotfiles_info "Configuring macOS..."

osascript -e 'tell application "System Settings" to quit'

# Make the app switcher (cmd+tab) visible on all displays
defaults write com.apple.Dock appswitcher-all-displays -bool true

# Only show active apps in the dock
defaults write com.apple.dock "static-only" -bool "true"

# Don't show recent or suggested apps in dock
defaults write com.apple.dock show-recents -bool false

# Make dock tiny and hide it away
defaults write com.apple.dock "tilesize" -int "24"
defaults write com.apple.dock "autohide" -bool "true"

# Set column view as default for Finder
defaults write com.apple.finder "FXPreferredViewStyle" -string "clmv"

# Show path bar in the bottom of the Finder windows
defaults write com.apple.finder "ShowPathbar" -bool "true"

# Make key repeats faster
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Repeat character when a key is held down for a long time, instead of showing character accents menu
defaults write NSGlobalDomain "ApplePressAndHoldEnabled" -bool "false"

# Save to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Add bluetooth to status bar
defaults -currentHost write com.apple.controlcenter.plist Bluetooth -int 18

# Disable annoying option-space keybinding from making nonbreaking spaces
keybindings_file="$HOME/Library/KeyBindings/DefaultKeyBinding.dict"
keybindings_contents='{
"~ " = ("insertText:", " ");
}'
if [ -s "${keybindings_file}" ]; then
	if ! grep -q '"~ " = ("insertText:", " ");' "${keybindings_file}"; then
		dotfiles_warn "${keybindings_file} exists but is missing the keybinding. Add it manually:"
		echo
		echo "${keybindings_contents}"
	fi
else
	mkdir -p "$HOME/Library/KeyBindings/"
	echo "${keybindings_contents}" > "${keybindings_file}"
fi

# Don't show icons on the desktop
defaults write com.apple.finder CreateDesktop -bool false

dotfiles_success "macOS configured. Log out and back in to see all changes take effect."
