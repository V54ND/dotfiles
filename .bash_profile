# shellcheck shell=bash

# Git Bash starts login shells from WezTerm, so keep the login entry point in git.
[ -r "$HOME/.profile" ] && source "$HOME/.profile"
[ -r "$HOME/.bashrc" ] && source "$HOME/.bashrc"
