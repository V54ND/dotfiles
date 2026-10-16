# shellcheck shell=bash

# zoxide must be last: its doctor checks that its hook is directly present in
# PROMPT_COMMAND, after Starship has installed its own prompt function.
case $- in
  *i*) ;;
  *) return 0 2>/dev/null || exit 0 ;;
esac

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash)"

  # zoxide 0.10.0 passes this command literally to cygpath under MSYS/Git Bash,
  # so its prompt hook cannot record the current directory. Keep the hook and
  # correct only the helper it calls. Remove this override once 0.10.1+ is used.
  if [[ -n ${MSYSTEM-} ]] && command -v cygpath >/dev/null 2>&1; then
    __zoxide_pwd() {
      command cygpath -w "$(builtin pwd -L)"
    }
  fi
fi
