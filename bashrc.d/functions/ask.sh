# Ask for permission to do something.
# For example usage, see `clean.sh`.
function ask {
    echo -n "$@" '[y/N] ' ; read ans
    case "$ans" in
        y*|Y*) return 0 ;;
        *) return 1 ;;
    esac
}
