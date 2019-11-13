export PATH="/Users/kjetilvalle/prosjekter/nsb/bin:$PATH"

export CMS_HOME="/Users/kjetilvalle/prosjekter/nsb/cms-ee-distro-4.7.11/home"

export NSB_SSH_CONFIG_DIR="/Users/kjetilvalle/nsb/dev/infrastructure/ssh_config"
#export NSB_SCRIPT_DIR="/Users/kjetilvalle/prosjekter/nsb/nsb.no-dev/scripts"


alias bd="cd backend && mvn clean install && cd .. && echo | envchain aws ./deploy.sh"
