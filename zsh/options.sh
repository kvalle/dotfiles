# ---------------------------------------------------------------------------
# Core zsh options
# ---------------------------------------------------------------------------
setopt CORRECT              # suggest corrections for commands
setopt NO_CASE_GLOB         # case-insensitive globbing
setopt EXTENDED_GLOB        # extended glob patterns
bindkey -e                  # emacs keybindings (ctrl+p/n for history, etc.)

# History
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY        # share history across sessions
setopt HIST_IGNORE_DUPS     # don't store duplicates
setopt HIST_IGNORE_SPACE    # don't store commands starting with space
setopt HIST_REDUCE_BLANKS   # remove extra blanks
