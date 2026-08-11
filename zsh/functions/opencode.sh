# ---------------------------------------------------------------------------
# OpenCode + cplt
# ---------------------------------------------------------------------------

# Shortcut for resuming the last session
alias occ="oc -c"

# ---------------------------------------------------------------------------
# Internal helpers
# ---------------------------------------------------------------------------

_oc_launch() {
  local remote token cplt_config exit_status
  remote=$(git remote get-url origin 2>/dev/null)

  if [[ "$remote" == (git@github.com:|https://github.com/|ssh://git@github.com/)kvalle/trene(|.git) ]]; then
    token=$(op read 'op://Private/GitHub cplt trene token/credential') || return
    cplt_config=$(mktemp "${TMPDIR:-/tmp}/cplt-trene.XXXXXX") || return
    sed 's/^allow_api_write = false$/allow_api_write = true/' ~/dotfiles/cplt/config.toml > "$cplt_config"
    GH_TOKEN="$token" \
      GIT_CONFIG_COUNT=3 \
      GIT_CONFIG_KEY_0='credential.https://github.com.helper' \
      GIT_CONFIG_VALUE_0='!f() { [ "$1" = get ] && printf "username=x-access-token\npassword=%s\n" "$GH_TOKEN"; }; f' \
      GIT_CONFIG_KEY_1='url.https://github.com/.insteadOf' \
      GIT_CONFIG_VALUE_1='git@github.com:' \
      GIT_CONFIG_KEY_2='url.https://github.com/.insteadOf' \
      GIT_CONFIG_VALUE_2='ssh://git@github.com/' \
      CPLT_CONFIG="$cplt_config" \
      cplt \
        --allow-localhost 5037 \
        --pass-env GIT_CONFIG_COUNT \
        --pass-env GIT_CONFIG_KEY_0 \
        --pass-env GIT_CONFIG_VALUE_0 \
        --pass-env GIT_CONFIG_KEY_1 \
        --pass-env GIT_CONFIG_VALUE_1 \
        --pass-env GIT_CONFIG_KEY_2 \
        --pass-env GIT_CONFIG_VALUE_2 \
        "$@"
    exit_status=$?
    rm -f "$cplt_config"
    return $exit_status
  else
    cplt "$@"
  fi
}

_oc_help() {
  cat <<EOF
${_c_bold}oc${_c_reset} ${_c_dim}–${_c_reset} OpenCode (runs in a cplt sandbox)

${_c_bold}Usage:${_c_reset}
  ${_c_green}oc${_c_reset}                  Start opencode.
  ${_c_green}oc${_c_reset} ${_c_yellow}s${_c_reset} ${_c_yellow}<id>${_c_reset}           Resume a specific session.
  ${_c_green}oc${_c_reset} ${_c_yellow}--${_c_reset} ${_c_yellow}[args]${_c_reset}        Pass arguments straight to opencode.
  ${_c_green}oc${_c_reset} ${_c_yellow}-<flag>${_c_reset}          Opencode flags are passed through ${_c_dim}(e.g. oc -c)${_c_reset}.

${_c_bold}Parallel agents with worktrees:${_c_reset}
  ${_c_green}oc${_c_reset} ${_c_yellow}w${_c_reset} ${_c_yellow}<branch>${_c_reset}       Create a worktree and start opencode there.
                      ${_c_dim}Goes to the existing worktree if there is one.${_c_reset}
                      ${_c_dim}Placed as a sibling directory: reponame--branch${_c_reset}
                      ${_c_dim}(/ in branch names is replaced with -)${_c_reset}
  ${_c_green}oc${_c_reset} ${_c_yellow}w${_c_reset}                Pick among existing worktrees ${_c_dim}(fzf)${_c_reset}.
  ${_c_green}oc${_c_reset} ${_c_yellow}wrm${_c_reset} ${_c_yellow}[branch]${_c_reset}     Remove a worktree and optionally its branch.
                      ${_c_dim}With no argument, removes the worktree you are in.${_c_reset}
  ${_c_green}oc${_c_reset} ${_c_yellow}wls${_c_reset}              List all worktrees for the current repo.

${_c_bold}Alias:${_c_reset}
  ${_c_green}occ${_c_reset}                 Shortcut for ${_c_dim}'oc -c'${_c_reset} (resume the last session).
EOF
}

_oc_session() {
  local id="$1"
  if [[ -z "$id" ]]; then
    echo "Usage: oc s <session-id>"
    return 1
  fi
  _oc_launch -- -s "$id"
}

# Returns the path to the main repository's worktree (the primary one)
_oc_main_root() {
  git worktree list --porcelain | head -1 | sed 's/worktree //'
}

# Check that fzf is available
_oc_require_fzf() {
  if ! command -v fzf &>/dev/null; then
    echo "fzf is required for this function. Install it with: brew install fzf"
    return 1
  fi
}

_oc_worktree() {
  local branch="$1"
  local repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
  local worktree_created=false

  if [[ -z "$repo_root" ]]; then
    echo "Not inside a git repository."
    return 1
  fi

  local repo_name=$(basename "$repo_root")

  # Without a branch argument: fzf picker over worktrees and branches
  if [[ -z "$branch" ]]; then
    _oc_require_fzf || return 1
    local main_root=$(_oc_main_root)

    # Collect existing worktrees (excluding the main repository)
    local entries=""
    local worktree_branches=()
    # Put the main repository at the top of the list
    local main_branch=$(git -C "$main_root" symbolic-ref --short HEAD 2>/dev/null)
    if [[ -n "$main_branch" ]]; then
      entries+="[main repo]"$'\t'"${main_branch}"$'\t'"${main_root}"$'\n'
      worktree_branches+=("$main_branch")
    fi
    while IFS= read -r line; do
      [[ -z "$line" ]] && continue
      local wt_path=$(echo "$line" | awk '{print $1}')
      local wt_branch=$(echo "$line" | sed 's/.*\[//;s/\].*//')
      worktree_branches+=("$wt_branch")
      entries+="[worktree]"$'\t'"${wt_branch}"$'\t'"${wt_path}"$'\n'
    done <<< "$(git worktree list | tail -n +2)"

    # Collect branches without an existing worktree
    while IFS= read -r b; do
      [[ -z "$b" ]] && continue
      local is_worktree=false
      for wb in "${worktree_branches[@]}"; do
        [[ "$b" == "$wb" ]] && is_worktree=true && break
      done
      if [[ "$is_worktree" == false ]]; then
        entries+="[branch]"$'\t'"${b}"$'\n'
      fi
    done <<< "$(git branch --format='%(refname:short)' | grep -v "^$(git symbolic-ref --short HEAD 2>/dev/null)$")"

    if [[ -z "$entries" ]]; then
      echo "No worktrees or branches found. Use 'oc w <branch>' to create one."
      return 0
    fi

    local selected=$(echo -n "$entries" | fzf --prompt="Pick worktree/branch: " --height=~40%)
    if [[ -z "$selected" ]]; then
      return 0
    fi

    local type=$(echo "$selected" | awk -F'\t' '{print $1}')
    local selected_branch=$(echo "$selected" | awk -F'\t' '{print $2}')

    if [[ "$type" == "[worktree]" || "$type" == "[main repo]" ]]; then
      local worktree_dir=$(echo "$selected" | awk -F'\t' '{print $3}')
      cd "$worktree_dir" || { echo "Could not change to: $worktree_dir"; return 1; }
      _oc_launch
    else
      # Create a worktree for an existing branch
      _oc_worktree "$selected_branch"
    fi
    return
  fi

  # With a branch argument: create or go to the worktree
  local main_root=$(_oc_main_root)
  local safe_branch="${branch//\//-}"
  local worktree_dir="$(dirname "$main_root")/${repo_name}--${safe_branch}"

  # If the branch is checked out in the main repository, go there directly
  local main_branch=$(git -C "$main_root" symbolic-ref --short HEAD 2>/dev/null)
  if [[ "$branch" == "$main_branch" ]]; then
    cd "$main_root" || { echo "Could not change to: $main_root"; return 1; }
    _oc_launch
    return
  fi

  if [[ -d "$worktree_dir" ]]; then
    echo "Worktree already exists: $worktree_dir"
    read -q "?Go there and start opencode? [y/N] " || { echo; return 0; }
    echo
  elif git show-ref --verify --quiet "refs/heads/$branch" 2>/dev/null; then
    git worktree add "$worktree_dir" "$branch" || return 1
    worktree_created=true
  else
    git worktree add "$worktree_dir" -b "$branch" || return 1
    worktree_created=true
  fi

  if [[ "$worktree_created" == true && -f "$worktree_dir/.envrc" ]] && command -v direnv &>/dev/null; then
    if [[ -f "$main_root/.envrc" ]] && cmp -s "$main_root/.envrc" "$worktree_dir/.envrc"; then
      direnv allow "$worktree_dir/.envrc" || return 1
    else
      echo "The worktree has a new or changed .envrc. Run 'direnv allow' there before starting opencode."
      return 1
    fi
  fi

  cd "$worktree_dir" || { echo "Could not change to: $worktree_dir"; return 1; }
  _oc_launch
}

_oc_worktree_rm() {
  local branch="${1:-}"
  local repo_root=$(git rev-parse --show-toplevel 2>/dev/null)

  if [[ -z "$repo_root" ]]; then
    echo "Not inside a git repository."
    return 1
  fi

  # Without an argument: fzf picker with the current worktree as default
  if [[ -z "$branch" ]]; then
    _oc_require_fzf || return 1
    local worktrees=$(git worktree list | tail -n +2)
    if [[ -z "$worktrees" ]]; then
      echo "No worktrees to remove."
      return 0
    fi

    # Find the current worktree, if any, for fzf's default query
    local default_query=""
    if [[ -f "$repo_root/.git" ]]; then
      default_query=$(basename "$repo_root")
    fi

    local selected=$(echo "$worktrees" | fzf --prompt="Remove worktree: " --height=~40% --query="$default_query")
    if [[ -z "$selected" ]]; then
      return 0
    fi

    local worktree_dir=$(echo "$selected" | awk '{print $1}')
    branch=$(echo "$selected" | sed 's/.*\[//;s/\]//')
  fi

  # Find the main repository and the worktree path
  local main_root=$(_oc_main_root)
  local repo_name=$(basename "$main_root")
  local safe_branch="${branch//\//-}"
  local worktree_dir="${worktree_dir:-$(dirname "$main_root")/${repo_name}--${safe_branch}}"

  if [[ ! -d "$worktree_dir" ]]; then
    echo "Worktree not found: $worktree_dir"
    return 1
  fi

  # Cd back to the main repository if we are inside the worktree
  if [[ "$PWD" == "$worktree_dir" || "$PWD" == "$worktree_dir"/* ]]; then
    cd "$main_root" || { echo "Could not change to: $main_root"; return 1; }
  fi

  if ! git worktree remove "$worktree_dir" 2>/dev/null; then
    echo "The worktree has uncommitted changes."
    read -q "?Remove with --force? [y/N] " || { echo; return 0; }
    echo
    git worktree remove --force "$worktree_dir" || return 1
  fi
  echo "Worktree removed: $worktree_dir"

  read -q "?Delete branch '$branch' too? [y/N] " || { echo; return 0; }
  echo

  # Check whether the branch has unmerged changes (against the default branch)
  local default_branch=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|origin/||')
  default_branch="${default_branch:-main}"

  if git merge-base --is-ancestor "$branch" "$default_branch" 2>/dev/null; then
    # The branch was merged normally - safe to delete
    git branch -D "$branch"
  elif git diff "$default_branch" "$branch" --quiet 2>/dev/null; then
    # The content is on main (squash-merged) - safe to delete
    git branch -D "$branch"
  else
    echo "Branch '$branch' has changes that are not merged into '$default_branch'."
    read -q "?Delete anyway? [y/N] " || { echo; return 0; }
    echo
    git branch -D "$branch"
  fi
}

_oc_worktree_ls() {
  git worktree list
}

# ---------------------------------------------------------------------------
# Main function
# ---------------------------------------------------------------------------

oc() {
  case "${1:-}" in
    --help|-h)
      _oc_help
      ;;
    s)
      shift
      _oc_session "$@"
      ;;
    w)
      shift
      _oc_worktree "$@"
      ;;
    wrm)
      shift
      _oc_worktree_rm "$@"
      ;;
    wls)
      _oc_worktree_ls
      ;;
    --)
      shift
      _oc_launch -- "$@"
      ;;
    -*)
      _oc_launch -- "$@"
      ;;
    "")
      _oc_launch
      ;;
    *)
      echo "Unknown command: $1"
      echo
      _oc_help
      return 1
      ;;
  esac
}
