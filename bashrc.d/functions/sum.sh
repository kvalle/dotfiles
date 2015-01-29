# Ask for permission to do something.
# For example usage, see `clean.sh`.
function _sum {
    awk '{ sum += $1; } END { print sum; }' "$@"
}

function _avg() {
	awk '{ sum += $1; } END { print sum / NR; }' "$@"
}
