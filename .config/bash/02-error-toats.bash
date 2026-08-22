__prompt_error_status() {
    local exit_code=${STARSHIP_CMD_STATUS:-0}

    (( exit_code == 0 )) && return

    local history_entry history_id command_text
    history_entry=$(HISTTIMEFORMAT= history 1)
    history_entry=${history_entry#"${history_entry%%[![:space:]]*}"}
    history_id=${history_entry%%[[:space:]]*}
    command_text=${history_entry#"$history_id"}
    command_text=${command_text#"${command_text%%[![:space:]]*}"}
    command_text=${command_text//$'\033'/}

    # Starship can be reached through more than one prompt integration path.
    # The history number identifies one actual command, so the same command is
    # not logged twice while still allowing two identical commands in a row.
    local error_key="${history_id}:${exit_code}"
    if [ "${__prompt_last_error_key:-}" = "$error_key" ]; then
        return
    fi
    __prompt_last_error_key=$error_key

    mkdir -p "${XDG_STATE_HOME:-$HOME/.local/state}/bash"
    printf '%s\texit %s\t%s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$exit_code" "$command_text" \
      >> "${XDG_STATE_HOME:-$HOME/.local/state}/bash/errors.log"

    # Show a ble.sh-style status line without moving the cursor or redrawing
    # the existing input line. This is safe with Starship and any terminal.
    printf '\n\033[31m✗ command failed (exit %s)\033[0m\n' "$exit_code"
}

starship_precmd_user_func=__prompt_error_status

errors() {
    local log_file="${XDG_STATE_HOME:-$HOME/.local/state}/bash/errors.log"
    if [ ! -s "$log_file" ]; then
        printf 'Ошибок в журнале пока нет.\n'
        return 0
    fi
    tail -n "${1:-30}" "$log_file"
}
