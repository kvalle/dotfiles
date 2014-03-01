# Do your files contain any non-ASCII characters?
function non_ascii {
    if [ $# -eq 1 ]; then
        grep -P -n "[\x80-\xFF]" $1
    else
        echo "Usage: non_ascii FILENAME"
    fi
}
