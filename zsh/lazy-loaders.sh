# ---------------------------------------------------------------------------
# Lazy-loaded version managers
# ---------------------------------------------------------------------------

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
