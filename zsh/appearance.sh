# Keep Starship in sync with the current macOS appearance before each prompt.
autoload -Uz add-zsh-hook

_update_starship_appearance() {
  local config="$HOME/dotfiles/starship/starship.toml"
  local lazygit_config="$HOME/dotfiles/lazygit/config.yml"

  if [[ $(defaults read -g AppleInterfaceStyle 2>/dev/null) != Dark ]]; then
    config="$HOME/dotfiles/starship/starship-light.toml"
    lazygit_config+=",$HOME/dotfiles/lazygit/themes/everforest-contrast.yml"
  fi

  [[ $STARSHIP_CONFIG == $config ]] || export STARSHIP_CONFIG=$config
  [[ $LG_CONFIG_FILE == $lazygit_config ]] || export LG_CONFIG_FILE=$lazygit_config
}

_update_starship_appearance
add-zsh-hook precmd _update_starship_appearance
