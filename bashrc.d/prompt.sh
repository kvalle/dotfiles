# Extract name of git branch checked out at current working directory
function git_branch {
    git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

function _update_ps1 {
    rc=$?

    C_GREEN='\[\e[1;32m\]'
    C_RED='\[\e[1;31m\]'
    C_FADED='\[\e[2m\]'
    C_RESET='\[\e[0m\]'

    unset PS1_GIT PS1_HOST PS1_DIR

    [ -n "$(git_branch)" ] && PS1_GIT=" ${C_FADED}on${C_RESET} $(git_branch)"
    [ -n "${SSH_CONNECTION}" ] && PS1_HOST=" ${C_FADED}at${C_RESET} \h"
    [ $rc -eq 0 -o $rc -eq 130 ] && C_DIR=$C_GREEN || C_DIR=$C_RED
    PS1_DIR=" ${C_FADED}»${C_RESET} ${C_DIR}\W${C_RESET} "

    export PS1="${PS1_GIT}${PS1_HOST}${PS1_DIR}"
}

PROMPT_COMMAND='_update_ps1'
