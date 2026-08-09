# shellcheck shell=bash

case $- in
  *i*) ;;
  *) return 0 2>/dev/null || exit 0 ;;
esac

case "${DOTFILES_ENABLE_BLESH:-1}" in
  0|false|no|off) return 0 ;;
esac

_blesh_file="${XDG_DATA_HOME:-$HOME/.local/share}/blesh/ble.sh"

if [ -r "$_blesh_file" ]; then
  if [ -z "${USER:-}" ]; then
    USER=$(id -un)
    export USER
  fi

  # Load the editor before completion, history, and prompt integrations, then
  # attach it only after every Bash module has finished.
  # shellcheck disable=SC1090
  source -- "$_blesh_file" --attach=none
fi

unset _blesh_file
