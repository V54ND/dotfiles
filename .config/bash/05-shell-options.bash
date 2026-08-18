# shellcheck shell=bash

# Small interactive Bash quality-of-life settings.
case $- in
  *i*) ;;
  *) return 0 2>/dev/null || exit 0 ;;
esac

shopt -s checkwinsize
bind 'set completion-ignore-case on' 2>/dev/null || true
