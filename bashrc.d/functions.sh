# Include settings from other files
if [ -d ~/.bashrc.d/functions ]; then
    for fn_file in ~/.bashrc.d/functions/*.sh; do
        [ -x $fn_file ] && . $fn_file
    done
    unset fn_file
fi
