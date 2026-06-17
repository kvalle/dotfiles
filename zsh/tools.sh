# ---------------------------------------------------------------------------
# Tools (fast inits only)
# ---------------------------------------------------------------------------

# direnv
eval "$(direnv hook zsh)"

# thefuck — cached alias (saves ~60ms vs spawning Python on every shell start)
# Regenerated weekly; equivalent to `eval $(thefuck --alias fix)`
_thefuck_cache=~/.cache/zsh/thefuck-alias.zsh
if [[ ! -f "$_thefuck_cache" ]] || [[ -n "$_thefuck_cache"(#qN.mh+168) ]]; then
  mkdir -p ~/.cache/zsh
  thefuck --alias fix > "$_thefuck_cache"
fi
source "$_thefuck_cache"
unset _thefuck_cache

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'fzf-preview.sh {}'"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always --level=2 --icons {} | head -200'"
source ~/dotfiles/fzf-git.sh/fzf-git.sh

# atuin
eval "$(atuin init zsh --disable-up-arrow)"

# kubectl completion (cached, regenerated daily)
_kubectl_comp=~/.zsh_kubectl_completion
if [[ ! -f "$_kubectl_comp" ]] || [[ -n "$_kubectl_comp"(#qN.mh+24) ]]; then
  kubectl completion zsh > "$_kubectl_comp"
fi
source "$_kubectl_comp"
unset _kubectl_comp

# ssh — only load keys from Keychain if agent is empty (saves ~300ms)
# Replaces unconditional `ssh-add --apple-use-keychain`
ssh-add -l &>/dev/null || ssh-add --apple-use-keychain 2>/dev/null
