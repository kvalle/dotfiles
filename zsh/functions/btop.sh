# Select a btop theme without letting runtime changes modify the tracked config.
btop() {
  local config="$HOME/dotfiles/btop/btop.conf"
  local themes="$HOME/dotfiles/btop/themes"
  local theme='catppuccin_macchiato'
  local runtime_config saved_config exit_status

  (( $+functions[_update_terminal_appearance] )) && _update_terminal_appearance
  [[ $TERMINAL_APPEARANCE == light ]] && theme='everforest-light-contrast'

  runtime_config=$(mktemp "${TMPDIR:-/tmp}/btop.XXXXXX") || return
  saved_config=$(mktemp "${TMPDIR:-/tmp}/btop-saved.XXXXXX") || {
    rm -f "$runtime_config"
    return 1
  }
  sed "s/^color_theme = .*$/color_theme = \"$theme\"/" "$config" > "$runtime_config" || {
    rm -f "$runtime_config" "$saved_config"
    return 1
  }

  {
    command btop "$@" --config "$runtime_config" --themes-dir "$themes"
    exit_status=$?
  } always {
    if sed 's/^color_theme = .*$/color_theme = "Default"/' "$runtime_config" > "$saved_config"; then
      if ! cmp -s "$saved_config" "$config" && ! cp "$saved_config" "$config"; then
        print -u2 -- 'btop: could not save config changes'
      fi
    else
      print -u2 -- 'btop: could not save config changes'
    fi
    rm -f "$runtime_config" "$saved_config"
  }
  return $exit_status
}
