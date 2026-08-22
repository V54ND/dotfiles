# shellcheck shell=bash

# zoxide must be last: its doctor checks that its hook is directly present in
# PROMPT_COMMAND, after Starship has installed its own prompt function.
case $- in
  *i*) ;;
  *) return 0 2>/dev/null || exit 0 ;;
esac

command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash)"
