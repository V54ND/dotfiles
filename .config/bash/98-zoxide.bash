# shellcheck shell=bash

# Initialize zoxide before the final Starship prompt hook.
case $- in
  *i*) ;;
  *) return 0 2>/dev/null || exit 0 ;;
esac

command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash)"
