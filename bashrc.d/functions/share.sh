function share() {
	python -m SimpleHTTPServer ${1:-1337}
}
