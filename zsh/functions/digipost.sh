# ---------------------------------------------------------------------------
# Digipost – cd with optional subdirectory target
# ---------------------------------------------------------------------------

cddp() {
  local base="${DIGIPOST_HOME:-$HOME/code/digipost}"

  if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    cat <<EOF
${_c_bold}cddp${_c_reset} ${_c_dim}–${_c_reset} quick cd to ${_c_cyan}\$DIGIPOST_HOME${_c_reset} ${_c_dim}($base)${_c_reset}

${_c_bold}Usage:${_c_reset}
  ${_c_green}cddp${_c_reset}              Pick a directory interactively via fzf ${_c_dim}("." = root)${_c_reset}
  ${_c_green}cddp${_c_reset} ${_c_yellow}<dir>${_c_reset}        Go straight to \$DIGIPOST_HOME/${_c_yellow}<dir>${_c_reset}
  ${_c_green}cddp${_c_reset} ${_c_yellow}--help${_c_reset}       Show this help text

${_c_bold}TAB completion:${_c_reset}
  ${_c_green}cddp${_c_reset} ${_c_yellow}<TAB>${_c_reset}        Standard zsh completion over subdirectories
EOF
    return 0
  fi

  if [[ -n "$1" ]]; then
    cd "$base/$1" || return 1
    return
  fi

  # No argument: if fzf is available, pick interactively; otherwise just cd
  if command -v fzf &>/dev/null; then
    local -a dirs
    dirs=("${(@f)$(find "$base" -maxdepth 1 -mindepth 1 -type d -exec basename {} \; 2>/dev/null)}")
    if (( ${#dirs} )); then
      local selected
      selected=$(printf '%s\n' "." "${dirs[@]}" | fzf --height=~40% --prompt="cddp > ")
      if [[ "$selected" == "." ]]; then
        cd "$base" || return 1
      elif [[ -n "$selected" ]]; then
        cd "$base/$selected" || return 1
      fi
    else
      cd "$base" || return 1
    fi
  else
    cd "$base" || return 1
  fi
}

# ---------------------------------------------------------------------------
# TAB completion: lists subdirectories (standard zsh menu-select)
# ---------------------------------------------------------------------------

_cddp() {
  local base="${DIGIPOST_HOME:-$HOME/code/digipost}"
  local -a dirs
  dirs=("${(@f)$(find "$base" -maxdepth 1 -mindepth 1 -type d -exec basename {} \; 2>/dev/null)}")
  (( ${#dirs} )) && compadd -- "${dirs[@]}"
}
compdef _cddp cddp
