# Function for opening IntelliJ from the command line.
#
# Written because the bundled `idea` launcher floods the terminal with log
# noise when used directly.
idea() {
  if (( $# == 0 )); then
    open -a "IntelliJ IDEA"
  else
    open -a "IntelliJ IDEA" "$@"
  fi
}
