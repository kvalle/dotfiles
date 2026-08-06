# Keep appearance-dependent tools in sync with macOS before each prompt.
autoload -Uz add-zsh-hook

_terminal_appearance() {
  if (( $+commands[defaults] )) &&
      [[ $(defaults read -g AppleInterfaceStyle 2>/dev/null) == Dark ]]; then
    print -r -- dark
  else
    print -r -- light
  fi
}

_update_terminal_appearance() {
  local appearance=$(_terminal_appearance)

  [[ $TERMINAL_APPEARANCE == $appearance ]] && return

  local starship_config="$HOME/dotfiles/starship/starship.toml"
  local lazygit_config="$HOME/dotfiles/lazygit/config.yml"
  local bat_theme='Catppuccin Macchiato'
  local delta_features='catppuccin-macchiato'
  local fzf_colors='bg+:#363a4f,bg:#24273a,spinner:#f4dbd6,hl:#ed8796,fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6,marker:#f4dbd6,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796'

  if [[ $appearance == light ]]; then
    starship_config="$HOME/dotfiles/starship/starship-light.toml"
    lazygit_config+=",$HOME/dotfiles/lazygit/themes/everforest-contrast.yml"
    # Replaced with the custom Everforest syntax theme in Ticket 4.
    bat_theme='Monokai Extended Light'
    delta_features='everforest-contrast'
    fzf_colors='bg+:#e4e8bd,bg:#fffbef,spinner:#c65f18,hl:#b83f3d,fg:#3d4c4f,header:#b83f3d,info:#aa4d8e,pointer:#c65f18,marker:#657a00,fg+:#3d4c4f,prompt:#2c7198,hl+:#b83f3d'
  fi

  export TERMINAL_APPEARANCE=$appearance
  export STARSHIP_CONFIG=$starship_config
  export LG_CONFIG_FILE=$lazygit_config
  export BAT_THEME=$bat_theme
  export DELTA_FEATURES=$delta_features
  export FZF_DEFAULT_OPTS="$FZF_BASE_OPTS --color=$fzf_colors"
}

_update_terminal_appearance
add-zsh-hook precmd _update_terminal_appearance
