alias ll="ls -l"

alias gll="git fetch && git pull"

function _compress() { 
  if [ -p /dev/stdin ]; then
    while IFS= read -r file; do
      ffmpeg -i "$file" -vcodec libx264 -crf 23 "${file%.*}-compressed.${file##*.}"
    done
  else
    for file in "$@"; do 
      ffmpeg -i "$file" -vcodec libx264 -crf 23 "${file%.*}-compressed.${file##*.}"
    done
  fi
}
alias compress='_compress'

function _togif() {
  if [ -p /dev/stdin ]; then
    while IFS= read -r file; do
      ffmpeg -i "$file" "${file%.*}.gif"
    done
  else
    for file in "$@"; do
      ffmpeg -i "$file" "${file%.*}.gif"
    done
  fi
}
alias togif='_togif'


eval "$(zoxide init bash)"
