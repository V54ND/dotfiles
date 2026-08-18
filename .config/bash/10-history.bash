# shellcheck shell=bash

# Persistent, shared Bash history. The prompt hook below flushes this session
# and imports commands written by other open Git Bash sessions.
export HISTFILE="$HOME/.bash_history"
export HISTSIZE=50000
export HISTFILESIZE=100000
export HISTCONTROL=ignoreboth:erasedups
export HISTIGNORE="ls:ll:la:l:cd:cd *:pwd:exit:clear:c"

shopt -s histappend
shopt -s cmdhist
shopt -s lithist

# @description
# Writes the current session history to disk and imports new history from other sessions.
#
# @example
#   __history_sync
#
# @stdout No output on success.
# @stderr History builtin errors.
#
# @exitcode 0 History was synced successfully.
__history_sync() {
  history -a
  history -n
}

# @description
# Adds the history sync hook to PROMPT_COMMAND unless it is already installed.
#
# @example
#   __history_install_prompt_command
#
# @stdout No output on success.
#
# @exitcode 0 The hook was installed or was already present.
__history_install_prompt_command() {
  case ";${PROMPT_COMMAND:-};" in
    *";__history_sync;"*) ;;
    *) PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }__history_sync" ;;
  esac
}
