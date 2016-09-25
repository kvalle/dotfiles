# Remove clutter from directory
function clean {
    dirty=`ls \#* *~ .*~ *.beam *.hi *.o *.class *.bak .*.bak *.pyc *.tmp .*.tmp core a.out 2>/dev/null`

    if [ -z "$dirty" ]; then
        echo "Nothing to clean"
        return
    fi

    C_BOLD='\e[1m'
    C_RESET='\e[0m'
    echo -ne "Will be cleaned: ${C_BOLD}"
    echo $dirty
    echo -ne "${C_RESET}"

    if ask "Proceed?"; then
       rm -f $dirty
       echo "Cleaned.";
    else
       echo "Aborted.";
    fi
}
