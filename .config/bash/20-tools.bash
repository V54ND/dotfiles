# shellcheck shell=bash

# Interactive tool integration. Load completion before Starship, then append
# the history sync hook so the prompt retains the previous command status.
case $- in
  *i*) ;;
  *) return 0 2>/dev/null || exit 0 ;;
esac

# Prefer the Git Bash completion shipped with Git, then use a system fallback.
for completion_file in \
  /usr/share/bash-completion/completions/git \
  /mingw64/share/git/completion/git-completion.bash
do
  if [ -r "$completion_file" ]; then
    # shellcheck disable=SC1090
    source "$completion_file"
    break
  fi
done
unset completion_file

# Fzf supplies Ctrl-R history search and shell key bindings when installed.
if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --bash)"
fi

command -v starship >/dev/null 2>&1 && eval "$(starship init bash)"

if declare -F __history_install_prompt_command >/dev/null 2>&1; then
  __history_install_prompt_command
fi
