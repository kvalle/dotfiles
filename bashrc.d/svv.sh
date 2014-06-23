cd /cygdrive/c/dev

export PATH=/cygdrive/c/dev/applications/Sublime-Text-2:$PATH
alias subl=sublime_text

alias byggserver='ssh extt04@svvuenobygg01'

function proxyon() {
	export http_proxy=proxy.vegvesen.no:8080
}

function proxyoff() {
	unset http_proxy
}
