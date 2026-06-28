# shellcheck shell=bash

export HISTFILE="$HOME/.bash_history"
export HISTSIZE=50000
export HISTFILESIZE=100000
export HISTCONTROL=ignoreboth:erasedups
export HISTIGNORE="ls:ll:la:l:cd:pwd:exit:clear:c"

shopt -s histappend
shopt -s cmdhist
shopt -s lithist

__history_sync() {
  builtin history -a
  builtin history -n
}

__history_install_prompt_command() {
  case ";${PROMPT_COMMAND:-};" in
    *";__history_sync;"*) ;;
    *) PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }__history_sync" ;;
  esac
}
