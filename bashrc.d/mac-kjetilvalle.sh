export PATH=$PATH:/Applications/Sublime\ Text.app/Contents/SharedSupport/bin
export PATH=$PATH:/Users/kjetilvalle/Library/Python/2.7/bin

export JAVA_HOME=`/usr/libexec/java_home -v 1.8`


# http://apple.stackexchange.com/questions/254468/macos-sierra-doesn-t-seem-to-remember-ssh-keys-between-reboots
{ eval `ssh-agent`; ssh-add -A; } &>/dev/null
