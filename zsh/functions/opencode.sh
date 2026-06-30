# ---------------------------------------------------------------------------
# OpenCode + cplt
# ---------------------------------------------------------------------------

# Snarvei for gjenoppta siste sesjon
alias occ="oc -c"

# ---------------------------------------------------------------------------
# Interne hjelpefunksjoner
# ---------------------------------------------------------------------------

_oc_help() {
  cat <<EOF
${_c_bold}oc${_c_reset} ${_c_dim}–${_c_reset} OpenCode (kjører i cplt-sandbox)

${_c_bold}Bruk:${_c_reset}
  ${_c_green}oc${_c_reset}                  Start opencode.
  ${_c_green}oc${_c_reset} ${_c_yellow}s${_c_reset} ${_c_yellow}<id>${_c_reset}           Gjenoppta en spesifikk sesjon.
  ${_c_green}oc${_c_reset} ${_c_yellow}--${_c_reset} ${_c_yellow}[args]${_c_reset}        Send argumenter direkte til opencode.
  ${_c_green}oc${_c_reset} ${_c_yellow}-<flagg>${_c_reset}         Opencode-flagg sendes videre ${_c_dim}(f.eks. oc -c)${_c_reset}.

${_c_bold}Parallelle agenter med worktrees:${_c_reset}
  ${_c_green}oc${_c_reset} ${_c_yellow}w${_c_reset} ${_c_yellow}<branch>${_c_reset}       Opprett et worktree og start opencode der.
                      ${_c_dim}Går til eksisterende worktree om det finnes.${_c_reset}
                      ${_c_dim}Plasseres som sibling-mappe: reponavn--branch${_c_reset}
                      ${_c_dim}(/ i branch-navn erstattes med -)${_c_reset}
  ${_c_green}oc${_c_reset} ${_c_yellow}w${_c_reset}                Velg blant eksisterende worktrees ${_c_dim}(fzf)${_c_reset}.
  ${_c_green}oc${_c_reset} ${_c_yellow}wrm${_c_reset} ${_c_yellow}[branch]${_c_reset}     Fjern et worktree og eventuelt tilhørende branch.
                      ${_c_dim}Uten argument fjernes worktree-et du står i.${_c_reset}
  ${_c_green}oc${_c_reset} ${_c_yellow}wls${_c_reset}              Vis alle worktrees for gjeldende repo.

${_c_bold}Alias:${_c_reset}
  ${_c_green}occ${_c_reset}                 Snarvei for ${_c_dim}'oc -c'${_c_reset} (gjenoppta siste sesjon).
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

# Returnerer stien til hovedrepoets worktree (den primære)
_oc_main_root() {
  git worktree list --porcelain | head -1 | sed 's/worktree //'
}

# Sjekk at fzf er tilgjengelig
_oc_require_fzf() {
  if ! command -v fzf &>/dev/null; then
    echo "fzf er påkrevd for denne funksjonen. Installer med: brew install fzf"
    return 1
  fi
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
    _oc_require_fzf || return 1
    local main_root=$(_oc_main_root)

    # Samle eksisterende worktrees (uten hovedrepoet)
    local entries=""
    local worktree_branches=()
    # Legg til hovedrepoet øverst i listen
    local main_branch=$(git -C "$main_root" symbolic-ref --short HEAD 2>/dev/null)
    if [[ -n "$main_branch" ]]; then
      entries+="[hovedrepo] ${main_branch}  ${main_root}"$'\n'
      worktree_branches+=("$main_branch")
    fi
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

    if [[ "$type" == "[worktree]" || "$type" == "[hovedrepo]" ]]; then
      local worktree_dir=$(echo "$selected" | awk '{print $3}')
      cd "$worktree_dir" || { echo "Kunne ikke gå til: $worktree_dir"; return 1; }
      cplt
    else
      # Opprett worktree for eksisterende branch
      _oc_worktree "$selected_branch"
    fi
    return
  fi

  # Med branch-argument: opprett eller gå til worktree
  local main_root=$(_oc_main_root)
  local safe_branch="${branch//\//-}"
  local worktree_dir="$(dirname "$main_root")/${repo_name}--${safe_branch}"

  # Hvis branchen er sjekket ut i hovedrepoet, gå dit direkte
  local main_branch=$(git -C "$main_root" symbolic-ref --short HEAD 2>/dev/null)
  if [[ "$branch" == "$main_branch" ]]; then
    cd "$main_root" || { echo "Kunne ikke gå til: $main_root"; return 1; }
    cplt
    return
  fi

  if [[ -d "$worktree_dir" ]]; then
    echo "Worktree finnes allerede: $worktree_dir"
    read -q "?Gå dit og start opencode? [y/N] " || { echo; return 0; }
    echo
  elif git show-ref --verify --quiet "refs/heads/$branch" 2>/dev/null; then
    git worktree add "$worktree_dir" "$branch"
  else
    git worktree add "$worktree_dir" -b "$branch"
  fi

  cd "$worktree_dir" || { echo "Kunne ikke gå til: $worktree_dir"; return 1; }
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
    _oc_require_fzf || return 1
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
    branch=$(echo "$selected" | sed 's/.*\[//;s/\]//')
  fi

  # Finn hovedrepoet og worktree-sti
  local main_root=$(_oc_main_root)
  local repo_name=$(basename "$main_root")
  local safe_branch="${branch//\//-}"
  local worktree_dir="${worktree_dir:-$(dirname "$main_root")/${repo_name}--${safe_branch}}"

  if [[ ! -d "$worktree_dir" ]]; then
    echo "Fant ikke worktree: $worktree_dir"
    return 1
  fi

  # Cd tilbake til hovedrepoet hvis vi står i worktree-et
  if [[ "$PWD" == "$worktree_dir" || "$PWD" == "$worktree_dir"/* ]]; then
    cd "$main_root" || { echo "Kunne ikke gå til: $main_root"; return 1; }
  fi

  if ! git worktree remove "$worktree_dir" 2>/dev/null; then
    echo "Worktree-et har ucommittede endringer."
    read -q "?Fjerne med --force? [y/N] " || { echo; return 0; }
    echo
    git worktree remove --force "$worktree_dir" || return 1
  fi
  echo "Worktree fjernet: $worktree_dir"

  read -q "?Slette branch '$branch' også? [y/N] " || { echo; return 0; }
  echo

  # Sjekk om branchen har uflettede endringer (mot default branch)
  local default_branch=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|origin/||')
  default_branch="${default_branch:-main}"

  if git merge-base --is-ancestor "$branch" "$default_branch" 2>/dev/null; then
    # Branchen er merget normalt - trygt å slette
    git branch -D "$branch"
  elif git diff "$default_branch" "$branch" --quiet 2>/dev/null; then
    # Innholdet er på main (squash-merget) - trygt å slette
    git branch -D "$branch"
  else
    echo "Branchen '$branch' har endringer som ikke er flettet inn i '$default_branch'."
    read -q "?Slette likevel? [y/N] " || { echo; return 0; }
    echo
    git branch -D "$branch"
  fi
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
