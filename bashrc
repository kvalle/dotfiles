# If not running interactively, don't do anything
#[ -z "$PS1" ] && return

# Don't put duplicates or lines beginning with spaces in the history.
HISTCONTROL=ignoredups:ignorespace

# Append to the history file, don't overwrite it.
shopt -s histappend

# Save all lines of a multiple-line command in the same history entry.
shopt -s cmdhist

# Mores sensible settings for bash history size.
HISTSIZE=10000
HISTFILESIZE=$HISTSIZE

# Check the window size after each command and, if necessary, update the 
# values of LINES and COLUMNS.
shopt -s checkwinsize

# Enable recursive globbing with `**`:
shopt -s globstar 2>/dev/null

# If set, and Readline is being used, Bash will not attempt to search the PATH
# for possible completions when completion is attempted on an empty line.
shopt -s no_empty_cmd_completion

# Make sure programmable completion features is enabled.
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# Set default editor
export EDITOR=vim

export PATH="$PATH:~/dotfiles/bin"

alias ll='ls -lh'
alias la='ls -lah'

###
###
### Everything below thie point is configuring the shell prompt
###
###

# Set up symbols
synced_symbol=""
dirty_synced_symbol="*"
unpushed_symbol="△"
dirty_unpushed_symbol="▲"
unpulled_symbol="▽"
dirty_unpulled_symbol="▼"
unpushed_unpulled_symbol="⬡"
dirty_unpushed_unpulled_symbol="⬢"

get_git_branch() {
  # On branches, this will return the branch name
  # On non-branches, (no branch)
  local ref="$(git symbolic-ref HEAD 2> /dev/null | sed -e 's/refs\/heads\///')"
  if [ "$ref" ]; then
    echo "$ref"
  else
    echo "(no branch)"
  fi
}

get_git_progress() {
  # Detect in-progress actions (e.g. merge, rebase)
  # https://github.com/git/git/blob/v1.9-rc2/wt-status.c#L1199-L1241
  local git_dir="$(git rev-parse --git-dir)"

  # git merge
  if [[ -f "$git_dir/MERGE_HEAD" ]]; then
    echo " [merge]"
  elif [[ -d "$git_dir/rebase-apply" ]]; then
    # git am
    if [[ -f "$git_dir/rebase-apply/applying" ]]; then
      echo " [am]"
      # git rebase
    else
      echo " [rebase]"
    fi
  elif [[ -d "$git_dir/rebase-merge" ]]; then
    # git rebase --interactive/--merge
    echo " [rebase]"
  elif [[ -f "$git_dir/CHERRY_PICK_HEAD" ]]; then
    # git cherry-pick
    echo " [cherry-pick]"
  fi
  if [[ -f "$git_dir/BISECT_LOG" ]]; then
    # git bisect
    echo " [bisect]"
  fi
  if [[ -f "$git_dir/REVERT_HEAD" ]]; then
    # git revert --no-commit
    echo " [revert]"
  fi
}

is_branch1_behind_branch2() {
  # $ git log origin/master..master -1
  # commit 4a633f715caf26f6e9495198f89bba20f3402a32
  # Author: Todd Wolfson <todd@twolfson.com>
  # Date:   Sun Jul 7 22:12:17 2013 -0700
  #
  #     Unsynced commit

  # Find the first log (if any) that is in branch1 but not branch2
  local first_log="$(git log $1..$2 -1 2> /dev/null)"

  # Exit with 0 if there is a first log, 1 if there is not
  [ "$first_log" ]
}

branch_exists() {
  # List remote branches           | # Find our branch and exit with 0 or 1 if found/not found
  git branch --remote 2> /dev/null | grep --quiet "$1"
}

parse_git_ahead() {
  # Grab the local and remote branch
  local branch="$(get_git_branch)"
  local remote_branch="origin/$branch"

  # $ git log origin/master..master
  # commit 4a633f715caf26f6e9495198f89bba20f3402a32
  # Author: Todd Wolfson <todd@twolfson.com>
  # Date:   Sun Jul 7 22:12:17 2013 -0700
  #
  #     Unsynced commit

  # If the remote branch is behind the local branch
  # or it has not been merged into origin (remote branch doesn't exist)
  if is_branch1_behind_branch2 "$remote_branch" "$branch" ||
    ! branch_exists "$remote_branch"; then
    # echo our character
    echo 1
  fi
}

parse_git_behind() {
  # Grab the branch
  local branch="$(get_git_branch)"
  local remote_branch="origin/$branch"

  # $ git log master..origin/master
  # commit 4a633f715caf26f6e9495198f89bba20f3402a32
  # Author: Todd Wolfson <todd@twolfson.com>
  # Date:   Sun Jul 7 22:12:17 2013 -0700
  #
  #     Unsynced commit

  # If the local branch is behind the remote branch
  if is_branch1_behind_branch2 "$branch" "$remote_branch"; then
    # echo our character
    echo 1
  fi
}

parse_git_dirty() {
  # If the git status has *any* changes (e.g. dirty), echo our character
  if [ "$(git status --porcelain 2> /dev/null)" ]; then
    echo 1
  fi
}

get_git_status() {
  # Grab the git dirty and git behind
  local dirty_branch="$(parse_git_dirty)"
  local branch_ahead="$(parse_git_ahead)"
  local branch_behind="$(parse_git_behind)"

  # Iterate through all the cases and if it matches, then echo
  if [[ "$dirty_branch" == 1 && "$branch_ahead" == 1 && "$branch_behind" == 1 ]]; then
    echo "$dirty_unpushed_unpulled_symbol"
  elif [[ "$branch_ahead" == 1 && "$branch_behind" == 1 ]]; then
    echo "$unpushed_unpulled_symbol"
  elif [[ "$dirty_branch" == 1 && "$branch_ahead" == 1 ]]; then
    echo "${dirty_unpushed_symbol}"
  elif [[ "$branch_ahead" == 1 ]]; then
    echo "$unpushed_symbol"
  elif [[ "$dirty_branch" == 1 && "$branch_behind" == 1 ]]; then
    echo "$dirty_unpulled_symbol"
  elif [[ "$branch_behind" == 1 ]]; then
    echo "$unpulled_symbol"
  elif [[ "$dirty_branch" == 1 ]]; then
    echo "$dirty_synced_symbol"
  else # clean
    echo "$synced_symbol"
  fi
}

get_git_info() {
  # Grab the branch
  local branch="$(get_git_branch)"

  # If there are any branches
  if [ "$branch" ]; then
    # The branch and git status
    echo "$branch $(get_git_status)"
  fi
}

is_on_git() {
  git rev-parse 2> /dev/null
}

function _update_ps1 {
    rc=$?

    C_GREEN='\[\e[1;32m\]'
    C_RED='\[\e[1;31m\]'
    C_BLUE='\[\e[1;34m\]'
    C_FADED='\[\e[2m\]'
    C_RESET='\[\e[0m\]'

    unset PS1_GIT PS1_HOST PS1_DIR

    is_on_git && PS1_GIT=" ${C_FADED}on${C_RESET} $(get_git_info)$(get_git_progress)"
    [ -n "${SSH_CONNECTION}" ] && PS1_HOST=" ${C_FADED}at${C_RESET} ${C_BLUE}\h${C_RESET}"
    [ $rc -eq 0 -o $rc -eq 130 ] && C_DIR=$C_GREEN || C_DIR=$C_RED
    PS1_DIR=" ${C_FADED}»${C_RESET} ${C_DIR}\W${C_RESET} "

    export PS1="${PS1_GIT}${PS1_HOST}${PS1_DIR}"
}

PROMPT_COMMAND='_update_ps1'

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
