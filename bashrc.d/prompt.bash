# First we define some colors
text_black='\e[0;30m'
text_red='\e[0;31m'
text_green='\e[0;32m'
text_yellow='\e[0;33m'
text_blue='\e[0;34m'
text_purple='\e[0;35m'
text_cyan='\e[0;36m'
text_white='\e[0;37m'

bold_black='\e[1;30m'
bold_red='\e[1;31m'
bold_green='\e[1;32m'
bold_yellow='\e[1;33m'
bold_blue='\e[1;34m'
bold_purple='\e[1;35m'
bold_cyan='\e[1;36m'
bold_white='\e[1;37m'

underline_black='\e[4;30m'
underline_red='\e[4;31m'
underline_green='\e[4;32m'
underline_yellow='\e[4;33m'
underline_blue='\e[4;34m'
underline_purple='\e[4;35m'
underline_cyan='\e[4;36m'
underline_white='\e[4;37m'

background_black='\e[40m'  
background_red='\e[41m'  
background_green='\e[42m'  
background_yellow='\e[43m'  
background_blue='\e[44m'  
background_purple='\e[45m'  
background_cyan='\e[46m'  
background_white='\e[47m'  

reset_color='\e[0m'

# Changing PS1 directory-color based on connection type
if [ -n "${SSH_CONNECTION}" ]; then
    # Connected on remote machine via ssh
    PS1_DIR_COLOR=${bold_blue}  
else
    # Connected on local machine.
    PS1_DIR_COLOR=${bold_green} 
fi

# Extract name of git branch checked out at current working directory
function parse_git_branch {
   git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ \1 at/'
}

# Customize prompt
export PS1="\$(parse_git_branch) \[${PS1_DIR_COLOR}\]\W\[${reset_color}\]$ "
