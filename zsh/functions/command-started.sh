autoload -Uz add-zsh-hook

command_started() {
  print -P "%F{8}󰥔 %D{%H:%M:%S}%f"
}

add-zsh-hook preexec command_started
