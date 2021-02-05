export PATH=$PATH:/Applications/Sublime\ Text.app/Contents/SharedSupport/bin
#export PATH=$PATH:/Users/kjetilvalle/Library/Python/2.7/bin
export PATH=$PATH:/Users/kjetilvalle/.local/bin

export JAVA_HOME=`/usr/libexec/java_home -v 15`

export M2_REPO="/Users/kjetilvalle/.m2/repository"

# http://apple.stackexchange.com/questions/254468/macos-sierra-doesn-t-seem-to-remember-ssh-keys-between-reboots
{ eval `ssh-agent`; ssh-add -A; } &>/dev/null

export PATH="/usr/local/opt/python/libexec/bin:$PATH"
