# shellcheck shell=bash

alias c='clear'
alias grep='grep --color=auto'
alias pbcopy='clip.exe'
alias pbpaste='powershell.exe -NoProfile -Command Get-Clipboard'

if command -v eza >/dev/null 2>&1; then
  alias l='eza --color=always --color-scale-mode=gradient --icons=always --group-directories-first'
  alias ll='eza --color=always --color-scale-mode=gradient --icons=always --group-directories-first -l --git -h'
  alias la='eza --color=always --color-scale-mode=gradient --icons=always --group-directories-first -a'
  alias lla='eza --color=always --color-scale-mode=gradient --icons=always --group-directories-first -a -l --git -h'
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
