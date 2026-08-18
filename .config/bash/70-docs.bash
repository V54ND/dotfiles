# shellcheck shell=bash

# Documentation helpers are loaded only when first used; they are not needed
# for normal interactive work.
case $- in
  *i*) ;;
  *) return 0 2>/dev/null || exit 0 ;;
esac

__bash_docs_loaded=0
__bash_docs_load() {
  [ "$__bash_docs_loaded" -eq 1 ] && return 0
  local docs_file="$XDG_CONFIG_HOME/bash/docs.sh"
  [ -r "$docs_file" ] || {
    echo "Error: Documentation helper not found: $docs_file" >&2
    return 1
  }
  # shellcheck disable=SC1090
  source "$docs_file" || return 1
  __bash_docs_loaded=1
}

bash_docs() {
  __bash_docs_load || return 1
  bash_docs "$@"
}

bash_docs_view() {
  __bash_docs_load || return 1
  bash_docs_view "$@"
}
