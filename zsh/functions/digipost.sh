# ---------------------------------------------------------------------------
# Digipost – cd with optional subdirectory target
# ---------------------------------------------------------------------------

cddp() {
  local base="${DIGIPOST_HOME:-$HOME/code/digipost}"

  if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    local bold=$'\e[1m' dim=$'\e[2m' reset=$'\e[0m'
    local cyan=$'\e[36m' green=$'\e[32m' yellow=$'\e[33m'
    cat <<EOF
${bold}cddp${reset} ${dim}–${reset} hurtig-cd til ${cyan}\$DIGIPOST_HOME${reset} ${dim}($base)${reset}

${bold}Bruk:${reset}
  ${green}cddp${reset}              Velg mappe interaktivt via fzf ${dim}("." = rot)${reset}
  ${green}cddp${reset} ${yellow}<mappe>${reset}      Gå direkte til \$DIGIPOST_HOME/${yellow}<mappe>${reset}
  ${green}cddp${reset} ${yellow}--help${reset}       Vis denne hjelpeteksten

${bold}TAB-completion:${reset}
  ${green}cddp${reset} ${yellow}<TAB>${reset}        Standard zsh-completion over undermapper
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
