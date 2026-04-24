import os
import os.path
from os.path import expanduser
import sys
import re
import rlcompleter, readline

readline.parse_and_bind("tab: complete")
sys.path.append(expanduser('~'))

sys.ps1='\033[32m> \033[m'
sys.ps2='\033[32m| \033[m'
