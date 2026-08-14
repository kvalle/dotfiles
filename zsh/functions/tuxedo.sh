# Select a Tuxedo theme without letting runtime changes modify the tracked theme choice.
tuxedo() {
  local config="$DOTFILES/tuxedo/config.toml"
  local themes="$DOTFILES/tuxedo/themes"
  local theme='Catppuccin Macchiato'
  local runtime_home runtime_config saved_config exit_status

  (( $+functions[_update_terminal_appearance] )) && _update_terminal_appearance
  [[ $TERMINAL_APPEARANCE == light ]] && theme='Everforest Light Contrast'

  runtime_home=$(mktemp -d "${TMPDIR:-/tmp}/tuxedo.XXXXXX") || return
  runtime_config="$runtime_home/tuxedo/config.toml"
  saved_config="$runtime_home/tuxedo/saved-config.toml"
  mkdir -p "$runtime_home/tuxedo" || {
    rm -rf "$runtime_home"
    return 1
  }
  ln -s "$themes" "$runtime_home/tuxedo/themes" || {
    rm -rf "$runtime_home"
    return 1
  }
  sed "s/^theme = .*$/theme = $theme/" "$config" > "$runtime_config" || {
    rm -rf "$runtime_home"
    return 1
  }

  {
    XDG_CONFIG_HOME="$runtime_home" command tuxedo "$@"
    exit_status=$?
  } always {
    if sed 's/^theme = .*$/theme = Terminal/' "$runtime_config" > "$saved_config"; then
      if ! cmp -s "$saved_config" "$config" && ! cp "$saved_config" "$config"; then
        print -u2 -- 'tuxedo: could not save config changes'
      fi
    else
      print -u2 -- 'tuxedo: could not save config changes'
    fi
    rm -rf "$runtime_home"
  }
  return $exit_status
}
