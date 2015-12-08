# Subpress cygwin warnings about windows style paths
export CYGWIN=nodosfilewarning

# Java
export JAVA6_HOME=/cygdrive/c/Java/jdk1.6.0_24
export JAVA7_HOME=/cygdrive/c/Java/jdk1.7.0_25
export JAVA8_HOME=/cygdrive/c/Java/jdk1.8.0_40
export JAVA_HOME=$JAVA8_HOME

# Add to PATH
export PATH=/cygdrive/c/dev/apps/gradle-2.3/bin:$PATH
export PATH=$JAVA_HOME/bin:$PATH
export PATH=/cygdrive/c/dev/apps/nodejs:$PATH

# Useful aliases
alias subl=sublime_text
alias byggserver='ssh extt04@svvuenobygg01'
alias ujapp08='ssh exthte@svvujapp08'
alias ujapp15='ssh extt04@svvujapp15'
alias inst='mvn clean install'
alias pint='mvn clean install -Pintegrationtests'

# SSH aliases KREG + kunde
alias kregum='ssh habor@139.116.11.11'
alias kregutm='ssh habor@139.116.11.10'
alias kregqa1='ssh svvuser1@139.116.10.207'
alias kregqa2='ssh svvuser1@139.116.10.208'
alias kregprod1='ssh svv_logg@139.116.10.30'
alias kregprod2='ssh svv_logg@139.116.10.31'
alias kregutv='ssh appadmin@139.116.11.91'
alias kundest='ssh habor@139.116.11.3'
alias kundeqa1='ssh svvuser1@139.116.10.195'
alias kundeqa2='ssh svvuser1@139.116.10.198'
alias kundeprod1='ssh svv_logg@139.116.10.20'
alias kundeprod2='ssh svv_logg@139.116.10.21'
alias kregbygg='ssh au2sys@139.116.11.6'


# Selvbetjening utilities
export UTILITIES_SCRIPTS=/cygdrive/c/dev/prosjekter/utilities/scripts
export PATH=$PATH:$UTILITIES_SCRIPTS

if [ -d $UTILITIES_SCRIPTS/felles ]; then
    for srcfile in $UTILITIES_SCRIPTS/felles/*.sh; do
        [ -x $srcfile ] && . $srcfile
    done
    unset srcfile
fi

## Useful functions

function java6(){
	export JAVA_HOME=$JAVA6_HOME
	export PATH=$JAVA_HOME/bin:$PATH
	java -version
	javac -version
	mvn --version
}

function java7(){
	export JAVA_HOME=$JAVA7_HOME
	export PATH=$JAVA_HOME/bin:$PATH
	java -version
	javac -version
	mvn --version
}

function java8(){
	export JAVA_HOME=$JAVA8_HOME
	export PATH=$JAVA_HOME/bin:$PATH
	java -version
	javac -version
	mvn --version
}

function pcd (){
	if [ $# -lt 1 ]; then
		echo "pcd - cd to folder matching PATTERN"
		echo
		echo "usage: pcd PATTERN [ROOT FOLDER]"
		return 1
	fi

	PATTERN=$(sed 's/\//.*\/.*/' <<<"$1")
	ROOT=${2:-"/cygdrive/c/dev/prosjekter"}
	FOLDER=$(find $ROOT -type d | grep $PATTERN | head -1)
	
	if [ $FOLDER ]; then
		cd $FOLDER
		echo "Boom! Teleported to:"
		echo -e "\033[39;1m`pwd`\033[0m"
	else
		echo -e "\033[39;1mI'm sorry, Dave. I'm afraid I can't do that.\033[0m"
		echo "(Also, I couldn't find '$1' anywhere.)"
	fi
}

function share() {
	python -m SimpleHTTPServer ${1:-1337}
}

function jetty() {
	mvn jetty:run -Djetty.port=${1:-1337}
}

## Stuff to do at startup
proxyon
cd /cygdrive/c/dev
