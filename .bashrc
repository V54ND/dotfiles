# shellcheck shell=bash

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

if [ -d "$XDG_CONFIG_HOME/bash" ]; then
  for file in "$XDG_CONFIG_HOME"/bash/*.bash; do
    [ -r "$file" ] && source "$file"
  done
fi
