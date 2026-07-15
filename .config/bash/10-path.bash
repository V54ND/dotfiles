# shellcheck shell=bash

# @description
# Prepends an existing directory to PATH when it is not already present.
#
# @arg $1 string Directory path to add to the front of PATH.
#
# @example
#   _path_prepend "$HOME/.local/bin"
#
# @exitcode 0 The directory was added, was already present, or was skipped.
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
