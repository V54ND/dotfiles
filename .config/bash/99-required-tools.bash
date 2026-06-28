# shellcheck shell=bash

case $- in
  *i*) ;;
  *) return 0 2>/dev/null || exit 0 ;;
esac

[ "${DOTFILES_CHECK_REQUIRED_TOOLS:-1}" = "0" ] && return 0

_required_tools=(
  starship
  zoxide
  fzf
  eza
  bat
  lazygit
  delta
  rg
  fd
  jq
  yazi
)
_missing_required_tools=()

for _required_tool in "${_required_tools[@]}"; do
  command -v "$_required_tool" >/dev/null 2>&1 ||
    _missing_required_tools+=("$_required_tool")
done

if [ "${#_missing_required_tools[@]}" -gt 0 ]; then
  echo "dotfiles: missing required CLI tools: ${_missing_required_tools[*]}" >&2
  echo "dotfiles: install with: scoop install starship zoxide fzf ripgrep fd bat eza lazygit delta jq yazi" >&2
fi

unset _required_tool _required_tools _missing_required_tools
