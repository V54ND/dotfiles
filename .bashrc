# shellcheck shell=bash

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

if [ -d "$XDG_CONFIG_HOME/bash" ]; then
  for file in "$XDG_CONFIG_HOME"/bash/*.bash; do
    [ -r "$file" ] || continue
    # shellcheck disable=SC1090
    source "$file"
  done
fi
