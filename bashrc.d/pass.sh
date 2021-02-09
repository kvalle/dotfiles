export PASSWORD_STORE_DIR=/Users/kjetilvalle/nsb/dev/.password-store
export KEYNAME="$(gpg -K | awk 'NR==4 {print $1}' | sed 's/2048R\///g')"

export GPG_TTY=$(tty)
gpg-connect-agent /bye 2> /dev/null
if [ $? -ne 0 ]; then
    eval $(gpg-agent --daemon)
fi
