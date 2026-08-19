# shellcheck shell=bash

# Portable interactive aliases. Tool-specific aliases have conservative
# fallbacks so the shell remains usable before optional tools are installed.
alias c='clear'
alias grep='grep --color=auto'

# Bash expands aliases while parsing name() function definitions. Clear any
# inherited clipboard aliases so this file remains safe to source repeatedly.
unalias pbcopy pbpaste 2>/dev/null || true

if command -v clip.exe >/dev/null 2>&1; then
  pbcopy() { clip.exe; }
fi

if command -v powershell.exe >/dev/null 2>&1; then
  pbpaste() { powershell.exe -NoProfile -Command 'Get-Clipboard -Raw'; }
fi

if command -v eza >/dev/null 2>&1; then
  alias l='eza --color=auto --color-scale-mode=gradient --icons=auto --group-directories-first'
  alias ll='eza --color=auto --color-scale-mode=gradient --icons=auto --group-directories-first -l --git -h'
  alias la='eza --color=auto --color-scale-mode=gradient --icons=auto --group-directories-first -a'
  alias lla='eza --color=auto --color-scale-mode=gradient --icons=auto --group-directories-first -a -l --git -h'
else
  alias l='ls'
  alias ll='ls -lh'
  alias la='ls -A'
  alias lla='ls -Alh'
fi

if command -v bat >/dev/null 2>&1; then
  alias cat='bat --paging=never --style=plain'
fi

if command -v lazygit >/dev/null 2>&1; then
  alias lg='lazygit'
fi
