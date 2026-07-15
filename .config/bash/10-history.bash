# shellcheck shell=bash

export HISTFILE="$HOME/.bash_history"
export HISTSIZE=50000
export HISTFILESIZE=100000
export HISTCONTROL=ignoreboth:erasedups
export HISTIGNORE="ls:ll:la:l:cd:pwd:exit:clear:c"

shopt -s histappend
shopt -s cmdhist
shopt -s lithist

# @description
# Writes the current session history to disk and imports new history from other sessions.
#
# @example
#   __history_sync
#
# @exitcode 0 History was synced successfully.
__history_sync() {
  builtin history -a
  builtin history -n
}

# @description
# Adds the history sync hook to PROMPT_COMMAND unless it is already installed.
#
# @example
#   __history_install_prompt_command
#
# @exitcode 0 The hook was installed or was already present.
__history_install_prompt_command() {
  case ";${PROMPT_COMMAND:-};" in
    *";__history_sync;"*) ;;
    *) PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }__history_sync" ;;
  esac
}
