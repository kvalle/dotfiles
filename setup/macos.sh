#!/bin/sh
set -e

# Make the app switcher (cmd+tab) visible on all displays
defaults write com.apple.Dock appswitcher-all-displays -bool true && killall Dock

# Only show active apps in the dock
defaults write com.apple.dock "static-only" -bool "true" && killall Dock

# Make dock tiny and hide it away
defaults write com.apple.dock "tilesize" -int "24" && killall Dock
defaults write com.apple.dock "autohide" -bool "true" && killall Dock

# Set column view as default for Finder
defaults write com.apple.finder "FXPreferredViewStyle" -string "clmv" && killall Finder

# Show path bar in the bottom of the Finder windows
defaults write com.apple.finder "ShowPathbar" -bool "true" && killall Finder

# Remove the 'Are you sure you want to open this application?' popup
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Make key repeats faster
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 10

# Repeat character when a key is held down for a long time, instead of showing character accents menu
defaults delete NSGlobalDomain "ApplePressAndHoldEnabled"

# Disable annoying option-space keybinding from making nonbreaking spaces
keybindings_file="/Users/kjetil/Library/KeyBindings/DefaultKeyBinding.dict"
keybindings_contents='{
"~ " = ("insertText:", " ");
}'
if [ -s ${keybindings_file} ]; then
	echo "${keybindings_file} already exists."
	echo "Please add the following contents manually:"
	echo
	echo "${keybindings_contents}"
else
	echo "${keybindings_contents}" > ${keybindings_file}
fi
