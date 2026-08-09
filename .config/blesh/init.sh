# shellcheck shell=bash

# Enable ble.sh completion and history suggestions after a short delay.
bleopt complete_auto_complete=1
bleopt complete_auto_delay=300
bleopt complete_auto_complete_opts-=history-disabled

# Keep transient errors short, silent, and non-flashing.
bleopt vbell_duration=500
bleopt edit_bell=vbell
bleopt vbell_default_message='------ Error ------'
ble-face -s vbell fg=red
ble-face -s vbell_flash fg=red
ble-face -s vbell_erase none

# Keep history synchronized between Bash sessions through ble.sh.
bleopt history_share=1

# Starship already renders exit status and command duration.
bleopt exec_errexit_mark=
bleopt exec_elapsed_mark=
bleopt exec_exit_mark=
bleopt prompt_eol_mark=''

# Load the official adapters after bash-completion and PATH initialization.
# Ctrl-R remains fzf-powered while both tools share the same line editor.
ble-import -d integration/fzf-completion
ble-import -d integration/fzf-key-bindings
