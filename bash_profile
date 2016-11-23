[[ -s ~/.bashrc ]] && source ~/.bashrc

## Init `nsb` script if it is present
NSB_SCRIPT="/Users/kjetilvalle/prosjekter/nsb/nsb.no-dev/scripts/bin/nsb"
[[ -s $NSB_SCRIPT ]] && eval "$($NSB_SCRIPT init -)"
