# shellcheck shell=bash

# Keep Starship last so all other startup files have finished composing hooks.
case $- in
  *i*) ;;
  *) return 0 2>/dev/null || exit 0 ;;
esac

command -v starship >/dev/null 2>&1 && eval "$(starship init bash)"
