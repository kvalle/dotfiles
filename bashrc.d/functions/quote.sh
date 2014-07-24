function quote() {
	#sources="cryptonomicon+dune+hitchhiker+starwars"
	sources="dune+hitchhiker+starwars"
	url="http://www.iheartquotes.com/api/v1/random?source=${sources}&max_lines=3"
	quote="$(wget --timeout=3 -O - -q $url)"
	echo "$quote" | sed 's/&quot;/"/g' | head -n -1
}
