alias ll="ls -l"

alias gf="git fetch"
alias gl="git pull"

alias compress='function _compress(){ ffmpeg -i "$1" -vcodec libx264 -crf 23 "${1%.*}-comp.${1##*.}"; }; _compress'

eval "$(zoxide init bash)"
