# Select a Superfile theme without duplicating the main configuration.
spf() {
  local config="$HOME/dotfiles/superfile/config.toml"
  local theme='catppuccin-macchiato'
  local runtime_config exit_status

  (( $+functions[_update_terminal_appearance] )) && _update_terminal_appearance
  [[ $TERMINAL_APPEARANCE == light ]] && theme='everforest-light-contrast'

  runtime_config=$(mktemp "${TMPDIR:-/tmp}/superfile.XXXXXX") || return
  sed "s/^theme = .*$/theme = \"$theme\"/" "$config" > "$runtime_config" || {
    rm -f "$runtime_config"
    return 1
  }

  {
    command spf --config-file "$runtime_config" "$@"
    exit_status=$?
  } always {
    rm -f "$runtime_config"
  }
  return $exit_status
}
