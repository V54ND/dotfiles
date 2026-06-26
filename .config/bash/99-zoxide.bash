# shellcheck shell=bash

case $- in
  *i*) ;;
  *) return 0 2>/dev/null || exit 0 ;;
esac

# zoxide checks that its hook is still present, so initialize it after prompt
# tools such as Starship have finished modifying PROMPT_COMMAND.
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash)"
