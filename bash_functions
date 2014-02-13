# Do your files contain any non-ASCII characters?
function non_ascii {
    if [ $# -eq 1 ]; then
        grep -P -n "[\x80-\xFF]" $1
    else
        echo "Usage: non_ascii FILENAME"
    fi
}

# Show which commands you use the most often
function freq_commands {
    history | awk '{$1 = ""; print}' | sort | uniq -c | sort -nr | less
}

# Sets terminal frame, if applicable
function xtitle() {
    case "$TERM" in
    *term* | rxvt)
        echo -en  "\e]0;$*\a" ;;
    *)  ;;
    esac
}

# Swap 2 filenames around, if they exist
function swap() { 
    local TMPFILE=tmp.$$

    [ $# -ne 2 ] && echo "swap: 2 arguments needed" && return 1
    [ ! -e $1 ] && echo "swap: $1 does not exist" && return 1
    [ ! -e $2 ] && echo "swap: $2 does not exist" && return 1

    mv "$1" $TMPFILE
    mv "$2" "$1"
    mv $TMPFILE "$2"
}

# Ask for permission to do something.
# For example usage, see clean() below.
function ask() {
    echo -n "$@" '[y/N] ' ; read ans
    case "$ans" in
        y*|Y*) return 0 ;;
        *) return 1 ;;
    esac
}

# Remove clutter from directory
function clean() {
    if ask "Really clean this directory?"; then
       rm -f \#* *~ .*~ *.beam *.class *.bak .*.bak *.pyc *.tmp .*.tmp core a.out;
       echo "Cleaned.";
    else
       echo "Not cleaned.";
    fi
}

# Source: http://bash.cyberciti.biz/guide/Getting_information_about_your_system
# Get info about host such as dns, IP, and hostname
function host_info(){
    local dnsips=$(sed -e '/^$/d' /etc/resolv.conf | awk '{if (tolower($1)=="nameserver") print $2}')
    echo "## Hostname and DNS information "
    echo "Hostname : $(hostname -s)"
    echo "DNS domain : $(hostname -d)"
    echo "Fully qualified domain name : $(hostname -f)"
    echo "Network address (IP) :  $(hostname -i)"
    echo "DNS name servers (DNS IP) : ${dnsips}"
}

# Purpose - Display used and free memory info
function mem_info(){
    echo "## Free and used memory "
    free -m
 
    echo "*********************************"
    echo "*** Virtual memory statistics ***"
    echo "*********************************"
    vmstat
    echo "***********************************"
    echo "*** Top 5 memory eating process ***"
    echo "***********************************"  
    ps auxf | sort -nr -k 4 | head -5   
}

# Display system information
function system_information() {
   printf "******** System Information ********\n" # display system information header
   printf "Hostname: \t\t %s\n" `hostname` # display host name
   printf "Uptime: \t\t %s\n" `uptime | awk ' { print $3 } ' | tr , ' '` # display the time that the system been up and running
   printf "Local filesystems: \t %s mounted\n" `mount | grep ^/dev | wc -l` # display local mounted hard drives
   printf "Filesystem \t\t Mount Point \t\t Size \t\t Free Space\n" # display header for hard drive informations
   df -h | grep ^/dev | awk ' { printf "%s \t\t %s \t\t\t %s \t\t %s\n", $1, $6, $2, $4 } ' # display hard drive information
   free -m | grep -i ^mem | awk ' { printf "Memory: \t\t %sM Total \t %sM Free\n", $2, $4  } ' # display memory information
   free -m | grep -i ^swap | awk ' { printf "Swap: \t\t\t %sM Total \t %sM Free\n\n", $2, $4  } ' # display swap memory information
}

function pi_motd() {
    let upSeconds="$(/usr/bin/cut -d. -f1 /proc/uptime)"
    let secs=$((${upSeconds}%60))
    let mins=$((${upSeconds}/60%60))
    let hours=$((${upSeconds}/3600%24))
    let days=$((${upSeconds}/86400))
    UPTIME=`printf "%d days, %02dh%02dm%02ds" "$days" "$hours" "$mins" "$secs"`

    # get the load averages
    read one five fifteen rest < /proc/loadavg

    echo "$(tput setaf 2)
     .~~.   .~~.    `date +"%A, %e %B %Y, %r"`
    '. \ ' ' / .'   `uname -srmo`$(tput setaf 1)
     .~ .~~~..~.
    : .~.'~'.~. :   Uptime.............: ${UPTIME}
   ~ (   ) (   ) ~  Memory.............: `cat /proc/meminfo | grep MemFree | awk {'print $2'}`kB (Free) / `cat /proc/meminfo | grep MemTotal | awk {'print $2'}`kB (Total)
  ( : '~'.~.'~' : ) Load Averages......: ${one}, ${five}, ${fifteen} (1, 5, 15 min)
   ~ .~ (   ) ~. ~  Running Processes..: `ps ax | wc -l | tr -d " "`
    (  : '~' :  )   IP Addresses.......: `/sbin/ifconfig eth0 | /bin/grep "inet addr" | /usr/bin/cut -d ":" -f 2 | /usr/bin/cut -d " " -f 1` and `wget -q -O - http://icanhazip.com/ | tail`
     '~ .~~~. ~'    Weather............: `curl -s "http://rss.accuweather.com/rss/liveweather_rss.asp?metric=1&locCode=EUR|UK|UK001|NAILSEA|" | sed -n '/Currently:/ s/.*: \(.*\): \([0-9]*\)\([CF]\).*/\2°\3, \1/p'`
         '~'
    $(tput sgr0)"
}

function mymotd() {
    echo
    echo "                               |  `date +"%A, %e %B %Y, %r"`"
    echo "                   . .         |  "
    echo "                 '.-:-.\`       |  Uptime...: `uptime | awk ' { print $3 } ' | tr , ' '`"
    echo "                 '  :  \`       |  IP.......: `wget -q -O - http://icanhazip.com/ | tail`"
    echo "              .-----:          |  Local IP.: `ifconfig wlan0 | grep "inet addr" | cut -d ":" -f 2 | cut -d " " -f 1`"
    echo "            .'       \`.        |"
    echo "     ,    /       (o) \\        |"
    echo "     \\\`._/          ,__)       |"
    echo "  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ |"
    echo ""
}


export MARKPATH=$HOME/.marks
function jump { 
    cd -P $MARKPATH/$1 2>/dev/null || echo "No such mark: $1"
}
function mark { 
    mkdir -p $MARKPATH; ln -s $(pwd) $MARKPATH/$1
}
function unmark { 
    rm -i $MARKPATH/$1 
}
function marks {
    ls -l $MARKPATH | sed 's/  / /g' | cut -d' ' -f9- | sed 's/ -/\t-/g' && echo
}
