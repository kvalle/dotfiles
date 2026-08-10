# ---------------------------------------------------------------------------
# Lazy-loaded version managers
# ---------------------------------------------------------------------------

# nvm - only loaded when you call nvm, node, npm, npx, etc.
# nvm is installed by Homebrew (see Brewfile), which keeps nvm.sh in the brew
# prefix instead of in NVM_DIR. NVM_DIR has to stay outside that prefix, or an
# upgrade of the formula takes the installed node versions with it.
export NVM_DIR="$HOME/.nvm"
_lazy_nvm() {
  unfunction nvm node npm npx 2>/dev/null
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
}
nvm()  { _lazy_nvm; nvm "$@" }
node() { _lazy_nvm; node "$@" }
npm()  { _lazy_nvm; npm "$@" }
npx()  { _lazy_nvm; npx "$@" }

# jenv — lazy-loaded with smart JAVA_HOME updates
# Instead of `eval "$(jenv init -)"` (which runs jenv rehash + sets a precmd hook
# that calls `jenv javahome` on every prompt), we add shims to PATH directly and
# only update JAVA_HOME when the directory actually changes.
export PATH="$HOME/.jenv/shims:$PATH"
_jenv_set_java_home() {
  [[ "$PWD" == "$_JENV_LAST_DIR" ]] && return
  _JENV_LAST_DIR=$PWD
  if [[ -f .java-version ]] || [[ -f "$HOME/.jenv/version" ]]; then
    export JAVA_HOME="$(jenv javahome 2>/dev/null)"
  fi
}
precmd_functions+=(_jenv_set_java_home)
# Full jenv (with rehash etc.) loaded on first explicit use
_lazy_jenv() {
  unfunction jenv 2>/dev/null
  eval "$(jenv init -)"
}
jenv() { _lazy_jenv; jenv "$@" }
