# shellcheck shell=bash

# Initialize Starship after the regular shell tools and before zoxide.
case $- in
  *i*) ;;
  *) return 0 2>/dev/null || exit 0 ;;
esac

command -v starship >/dev/null 2>&1 && eval "$(starship init bash)"
