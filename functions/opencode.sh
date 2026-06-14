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

  # Uten branch-argument: fzf-velger blant eksisterende worktrees
  if [[ -z "$branch" ]]; then
    local worktrees=$(git worktree list | tail -n +2)
    if [[ -z "$worktrees" ]]; then
      echo "Ingen worktrees funnet. Bruk 'oc w <branch>' for å opprette et."
      return 0
    fi

    local selected=$(echo "$worktrees" | fzf --prompt="Velg worktree: " --height=~40%)
    if [[ -z "$selected" ]]; then
      return 0
    fi

    local worktree_dir=$(echo "$selected" | awk '{print $1}')
    cd "$worktree_dir"
    cplt
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

  # Uten argument: foreslå worktree-et du står i
  if [[ -z "$branch" ]]; then
    if [[ -f "$repo_root/.git" ]]; then
      branch=$(basename "$repo_root" | sed "s/^.*--//")
      echo "Fjerne worktree for branch '$branch'? ($repo_root)"
      read -q "?Bekreft [y/N] " || { echo; return 0; }
      echo
    else
      echo "Bruk: oc wrm <branch> (eller stå i et worktree)"
      return 1
    fi
  fi

  # Finn hovedrepoet og worktree-sti
  local main_root=$(git worktree list --porcelain | head -1 | sed 's/worktree //')
  local repo_name=$(basename "$main_root")
  local worktree_dir="$(dirname "$main_root")/${repo_name}--${branch}"

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
  git branch -d "$branch" 2>/dev/null || git branch -D "$branch"
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
