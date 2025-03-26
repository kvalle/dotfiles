## Funksjon for å grep'e i git-historikken
## 
## første argument: det man vil søke etter
## andre argument (valgfritt): antall linjer kontekst rundt hvert treff
function ghs() {
	alias grep='grep --color=always'

	git log -S"$1" --format="%H" |
	while read commit_id
	do 
		echo -e "\e[1;34m$commit_id\e[0m"
		git show "$commit_id" | grep -C ${2:-0} "$1"
	done
}
