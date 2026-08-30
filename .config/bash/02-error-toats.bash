# shellcheck shell=bash

# @description
# Prints a ble.sh-style status line for the previous failed command.
# Starship calls this function immediately before rendering the next prompt.
#
# @stdout A red failure status line when the previous command failed.
# @stderr None.
#
# @exitcode 0 The status was ignored or displayed for this prompt cycle.
__prompt_error_status() {
    local exit_code=${STARSHIP_CMD_STATUS:-0}

    (( exit_code == 0 )) && return

    printf '\n\033[31m✗ command failed (exit %s)\033[0m\n' "$exit_code"
}

# shellcheck disable=SC2034
starship_precmd_user_func=__prompt_error_status
