[[ -s ~/.bashrc ]] && source ~/.bashrc

## Init `nsb` script if it is present
NSB_SCRIPT="/Users/kjetilvalle/nsb/dev/nsb.no-dev/scripts/bin/nsb"
if [[ -s $NSB_SCRIPT ]]; then
    eval "$($NSB_SCRIPT init -)"
else
	print "Error: Didn't find nsb script at '$NSB_SCRIPT'"
fi
