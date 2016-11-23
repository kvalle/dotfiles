export PASSWORD_STORE_DIR=/Users/kjetilvalle/prosjekter/nsb/.password-store
export KEYNAME="$(gpg2 -K | awk 'NR==3 {print $2}' | sed 's/2048R\///g')"
