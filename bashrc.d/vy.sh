export PATH="/Users/kjetilvalle/prosjekter/nsb/bin:$PATH"

export CMS_HOME="/Users/kjetilvalle/prosjekter/nsb/cms-ee-distro-4.7.11/home"

export NSB_SSH_CONFIG_DIR="/Users/kjetilvalle/nsb/dev/infrastructure/ssh_config"
#export NSB_SCRIPT_DIR="/Users/kjetilvalle/prosjekter/nsb/nsb.no-dev/scripts"


export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"

export GROOVY_HOME=/usr/local/opt/groovy/libexec

export NVM_DIR=~/.nvm
source $(brew --prefix nvm)/nvm.sh

alias bd="cd backend && mvn clean install && cd .. && echo | envchain aws ./deploy.sh"

alias ij="SPRING_PROFILES_ACTIVE=local AWS_REGION=eu-central-1 envchain aws idea"

function aal() {
  export AWS_DEFAULT_REGION=eu-west-1

  echo "Kontoer for KFK:"
  echo
  echo "  dev:     642842684000"
  echo "  test:    876003175777"
  echo
  echo "  stage:   799836969940"
  echo "  prod:    279767569529"
  echo
  echo "  service: 410823703486"
  echo
  echo

  aws-azure-login
}

