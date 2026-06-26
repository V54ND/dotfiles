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

__history_prompt_command_contains() {
  case ";${PROMPT_COMMAND:-};" in
    *";$1;"*) return 0 ;;
    *) return 1 ;;
  esac
}

__history_install_prompt_command() {
  __history_prompt_command_contains "__history_sync" && return 0

  # Keep status-aware prompt hooks first; Starship should see the real exit code.
  PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }__history_sync"
}

__history_install_prompt_command
