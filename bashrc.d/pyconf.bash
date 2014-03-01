export PYTHONSTARTUP=~/.pythonrc.py
export WORKON_HOME=~/pyenvs

if [ -f /usr/local/bin/virtualenvwrapper.sh ]; then
	source /usr/local/bin/virtualenvwrapper.sh

	# Automated changing of virtualenv when entering directories.
	# Written byJustin Lilly,
	# https://github.com/justinlilly/jlilly-bashy-dotfiles/commit/04899f005397499e89da6d562b062545e70d7975
	has_virtualenv() {
	    if [ -e .venv ]; then
			workon `cat .venv`
	    fi
	}

	venv_cd () {
	    cd "$@" && has_virtualenv
	}
	alias cd="venv_cd"
fi
