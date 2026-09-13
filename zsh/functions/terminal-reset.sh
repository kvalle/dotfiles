# Restore the terminal's standard character sets before resetting its state.
terminal-reset() {
  printf '\033(B\033)B\017'
  command reset
}
