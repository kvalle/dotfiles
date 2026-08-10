# Funksjon for å åpne Intellij fra kommandolinja.
#
# Laget fordi innebygget `idea` fører til en masse 
# logg-støy i terminalen når jeg bruker den direkte.
idea() {
  if (( $# == 0 )); then
    open -a "IntelliJ IDEA"
  else
    open -a "IntelliJ IDEA" "$@"
  fi
}
