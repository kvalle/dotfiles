
function svnrm() {
	# Does a `svn rm` on all files that have been deleted outside of 
	# SVN and thus appear with ! in the `svn status`

	files=$(svn st | grep '^!' | awk '{print $2}' | tr '\\' '/')
	echo -e "Press enter to SVN RM the following (^C to abort)"
	echo
	echo -e "$files"
	read
	echo $files | xargs svn rm
}

function svnignore() {
	# Utility function for ignoring files in SVN

	if [ -z "$1" ]; then
	    echo "Usage: svnignore <file to ignore>"
	    return
	fi
	dir=$(dirname $1)
	file=$(basename $1)

	ignored=$(svn propget svn:ignore $dir)
	svn propset svn:ignore "$ignored
$file" $dir
}

function svnadd() {
	# Add or ignore untracked files. Will prompt for each file SVN 
	# does't know about yet.

	files=$(svn st | grep '^?' | awk '{print $2}' | tr '\\' '/')
	for file in $files; do
		echo
		echo "$file"
		read -p "(a)dd, (i)gnore, (S)kip: " -n 1 -r
		echo
		if [[ $REPLY =~ ^[Ii]$ ]]; then
		    svnignore $file
		elif [[ $REPLY =~ ^[Aa]$ ]]; then
			svn add $file
			echo "Added $file"
		else
			echo "Skipped $file"
		fi
	done
}

alias svnrevert='svn revert . --recursive'
