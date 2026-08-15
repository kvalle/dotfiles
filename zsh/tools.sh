# ---------------------------------------------------------------------------
# Tools (fast inits only)
# ---------------------------------------------------------------------------

# direnv
eval "$(direnv hook zsh)"

# fnm — Node versions, switched on cd from .nvmrc or .node-version
# Initialised eagerly rather than lazy-loaded: fnm is a binary, so this costs a
# couple of milliseconds.
#
# fnm is the only source of Node — there is no system-wide install to fall back
# to. This line puts the `default` version on PATH; scripts/setup.sh installs one
# via dotfiles_use_node if none exists yet.
eval "$(fnm env --use-on-cd --shell zsh)"

# fzf
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
typeset -g FZF_BASE_OPTS='--height 40% --layout=reverse --border'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'fzf-preview.sh {}'"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always --level=2 --icons {} | head -200'"
source <(fzf --zsh)
source "$DOTFILES/fzf-git.sh/fzf-git.sh"

# atuin
eval "$(atuin init zsh --disable-up-arrow)"

# zoxide — smarter cd
export _ZO_RESOLVE_SYMLINKS=1
eval "$(zoxide init zsh --cmd cd)"

# ssh — only load keys from Keychain if agent is empty (saves ~300ms)
# Replaces unconditional `ssh-add --apple-use-keychain`
ssh-add -l &>/dev/null || ssh-add --apple-use-keychain 2>/dev/null
