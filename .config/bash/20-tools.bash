# shellcheck shell=bash

case $- in
  *i*) ;;
  *) return 0 2>/dev/null || exit 0 ;;
esac

for completion_file in \
  /usr/share/bash-completion/completions/git \
  /mingw64/share/git/completion/git-completion.bash
do
  if [ -r "$completion_file" ]; then
    source "$completion_file"
    break
  fi
done
unset completion_file

command -v fzf >/dev/null 2>&1 && eval "$(fzf --bash)"
command -v atuin >/dev/null 2>&1 && eval "$(atuin init bash)"

command -v starship >/dev/null 2>&1 && eval "$(starship init bash)"

if declare -F __history_install_prompt_command >/dev/null 2>&1; then
  __history_install_prompt_command
fi
