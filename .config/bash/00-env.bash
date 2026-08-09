# shellcheck shell=bash

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Environment variables inherited from Windows can use C:/... paths. Most
# Git Bash tools accept them, but shell frameworks that inspect BASH_SOURCE do
# not always resolve them correctly, so normalize them once at startup.
_xdg_normalize_path() {
  case "$1" in
    [[:alpha:]]:[\\/]*)
      if command -v cygpath >/dev/null 2>&1; then
        cygpath -u "$1"
      else
        printf '%s\n' "$1"
      fi
      ;;
    *) printf '%s\n' "$1" ;;
  esac
}

XDG_CONFIG_HOME=$(_xdg_normalize_path "$XDG_CONFIG_HOME")
XDG_CACHE_HOME=$(_xdg_normalize_path "$XDG_CACHE_HOME")
XDG_DATA_HOME=$(_xdg_normalize_path "$XDG_DATA_HOME")
XDG_STATE_HOME=$(_xdg_normalize_path "$XDG_STATE_HOME")

export XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME XDG_STATE_HOME
unset -f _xdg_normalize_path
