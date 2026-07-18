# ---------------------------------------------------------------------------
# Completion system
# ---------------------------------------------------------------------------
autoload -Uz compinit
# Only regenerate .zcompdump once per day
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'l:|=* r:|=*' # case-insensitive + substring
zstyle ':completion:*' menu select                          # menu selection
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"     # colored completions
zstyle ':completion:*' special-dirs true                     # complete . and ..

# Carapace — rich completions for 800+ commands
# Bridges: fall back to existing shell completions when carapace has none
export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
source <(carapace _carapace zsh)
