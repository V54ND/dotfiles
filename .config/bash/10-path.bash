# shellcheck shell=bash

_path_prepend() {
  [ -n "$1" ] || return 0
  [ -d "$1" ] || return 0

  case ":$PATH:" in
    *":$1:"*) ;;
    *) PATH="$1${PATH:+:$PATH}" ;;
  esac
}

_path_prepend "/c/ProgramData/scoop/shims"
_path_prepend "$HOME/scoop/shims"
_path_prepend "$HOME/.local/bin"

export PATH
unset -f _path_prepend
