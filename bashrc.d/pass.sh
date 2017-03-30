export PASSWORD_STORE_DIR=/Users/kjetilvalle/prosjekter/nsb/.password-store
export KEYNAME="$(gpg2 -K | awk 'NR==3 {print $2}' | sed 's/2048R\///g')"

export GPG_TTY=$(tty)
gpg-connect-agent /bye 2> /dev/null
if [ $? -ne 0 ]; then
    eval $(gpg-agent --daemon)
fi
