# ---------------------------------------------------------------------------
# OpenCode + cplt
# ---------------------------------------------------------------------------

# Snarvei for gjenoppta siste sesjon
alias occ="oc -c"

# ---------------------------------------------------------------------------
# Interne hjelpefunksjoner
# ---------------------------------------------------------------------------

_oc_help() {
  cat <<'EOF'
OpenCode (kjører i cplt-sandbox):

  oc                  Start opencode.
  oc s <id>           Gjenoppta en spesifikk sesjon.
  oc -- [args]        Send argumenter direkte til opencode.
  oc -<flagg>         Opencode-flagg sendes videre (f.eks. oc -c).

Parallelle agenter med worktrees:

  oc w <branch>       Opprett et worktree og start opencode der.
                      Går til eksisterende worktree om det finnes.
                      Plasseres som sibling-mappe: reponavn--branch
  oc w                Velg blant eksisterende worktrees (fzf).
  oc wrm [branch]     Fjern et worktree og eventuelt tilhørende branch.
                      Uten argument fjernes worktree-et du står i.
  oc wls              Vis alle worktrees for gjeldende repo.

Alias:
  occ                 Snarvei for 'oc -c' (gjenoppta siste sesjon).
EOF
}

_oc_session() {
  local id="$1"
  if [[ -z "$id" ]]; then
    echo "Bruk: oc s <sesjon-id>"
    return 1
  fi
  cplt -- -s "$id"
}

_oc_worktree() {
  local branch="$1"
  local repo_root=$(git rev-parse --show-toplevel 2>/dev/null)

  if [[ -z "$repo_root" ]]; then
    echo "Ikke inne i et git-repo."
    return 1
  fi

  local repo_name=$(basename "$repo_root")

  # Uten branch-argument: fzf-velger blant worktrees og branches
  if [[ -z "$branch" ]]; then
    local main_root=$(git worktree list --porcelain | head -1 | sed 's/worktree //')

    # Samle eksisterende worktrees (uten hovedrepoet)
    local entries=""
    local worktree_branches=()
    while IFS= read -r line; do
      [[ -z "$line" ]] && continue
      local wt_path=$(echo "$line" | awk '{print $1}')
      local wt_branch=$(echo "$line" | sed 's/.*\[//;s/\].*//')
      worktree_branches+=("$wt_branch")
      entries+="[worktree]  ${wt_branch}  ${wt_path}"$'\n'
    done <<< "$(git worktree list | tail -n +2)"

    # Samle branches uten eksisterende worktree
    while IFS= read -r b; do
      [[ -z "$b" ]] && continue
      local is_worktree=false
      for wb in "${worktree_branches[@]}"; do
        [[ "$b" == "$wb" ]] && is_worktree=true && break
      done
      if [[ "$is_worktree" == false ]]; then
        entries+="[branch]    ${b}"$'\n'
      fi
    done <<< "$(git branch --format='%(refname:short)' | grep -v "^$(git symbolic-ref --short HEAD 2>/dev/null)$")"

    if [[ -z "$entries" ]]; then
      echo "Ingen worktrees eller branches funnet. Bruk 'oc w <branch>' for å opprette et nytt."
      return 0
    fi

    local selected=$(echo -n "$entries" | fzf --prompt="Velg worktree/branch: " --height=~40%)
    if [[ -z "$selected" ]]; then
      return 0
    fi

    local type=$(echo "$selected" | awk '{print $1}')
    local selected_branch=$(echo "$selected" | awk '{print $2}')

    if [[ "$type" == "[worktree]" ]]; then
      local worktree_dir=$(echo "$selected" | awk '{print $3}')
      cd "$worktree_dir"
      cplt
    else
      # Opprett worktree for eksisterende branch
      _oc_worktree "$selected_branch"
    fi
    return
  fi

  # Med branch-argument: opprett eller gå til worktree
  local main_root=$(git worktree list --porcelain | head -1 | sed 's/worktree //')
  local worktree_dir="$(dirname "$main_root")/${repo_name}--${branch}"

  if [[ -d "$worktree_dir" ]]; then
    echo "Worktree finnes allerede: $worktree_dir"
    read -q "?Gå dit og start opencode? [y/N] " || { echo; return 0; }
    echo
  elif git show-ref --verify --quiet "refs/heads/$branch" 2>/dev/null; then
    git worktree add "$worktree_dir" "$branch"
  else
    git worktree add "$worktree_dir" -b "$branch"
  fi

  cd "$worktree_dir"
  cplt
}

_oc_worktree_rm() {
  local branch="${1:-}"
  local repo_root=$(git rev-parse --show-toplevel 2>/dev/null)

  if [[ -z "$repo_root" ]]; then
    echo "Ikke inne i et git-repo."
    return 1
  fi

  # Uten argument: fzf-velger med current worktree som default
  if [[ -z "$branch" ]]; then
    local worktrees=$(git worktree list | tail -n +2)
    if [[ -z "$worktrees" ]]; then
      echo "Ingen worktrees å fjerne."
      return 0
    fi

    # Finn eventuelt current worktree for default-valg i fzf
    local default_query=""
    if [[ -f "$repo_root/.git" ]]; then
      default_query=$(basename "$repo_root")
    fi

    local selected=$(echo "$worktrees" | fzf --prompt="Fjern worktree: " --height=~40% --query="$default_query")
    if [[ -z "$selected" ]]; then
      return 0
    fi

    local worktree_dir=$(echo "$selected" | awk '{print $1}')
    branch=$(basename "$worktree_dir" | sed "s/^.*--//")
  fi

  # Finn hovedrepoet og worktree-sti
  local main_root=$(git worktree list --porcelain | head -1 | sed 's/worktree //')
  local repo_name=$(basename "$main_root")
  local worktree_dir="${worktree_dir:-$(dirname "$main_root")/${repo_name}--${branch}}"

  if [[ ! -d "$worktree_dir" ]]; then
    echo "Fant ikke worktree: $worktree_dir"
    return 1
  fi

  # Cd tilbake til hovedrepoet hvis vi står i worktree-et
  if [[ "$PWD" == "$worktree_dir"* ]]; then
    cd "$main_root"
  fi

  git worktree remove "$worktree_dir"
  echo "Worktree fjernet: $worktree_dir"

  read -q "?Slette branch '$branch' også? [y/N] " || { echo; return 0; }
  echo

  # Sjekk om branchen har uflettede endringer (mot default branch)
  local default_branch=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|origin/||')
  default_branch="${default_branch:-main}"

  if ! git merge-base --is-ancestor "$branch" "$default_branch" 2>/dev/null; then
    echo "Branchen '$branch' har endringer som ikke er flettet inn i '$default_branch'."
    read -q "?Slette likevel? [y/N] " || { echo; return 0; }
    echo
  fi
  git branch -D "$branch"
}

_oc_worktree_ls() {
  git worktree list
}

# ---------------------------------------------------------------------------
# Hovedfunksjon
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
      cplt -- "$@"
      ;;
    -*)
      cplt -- "$@"
      ;;
    "")
      cplt
      ;;
    *)
      echo "Ukjent kommando: $1"
      echo
      _oc_help
      return 1
      ;;
  esac
}
