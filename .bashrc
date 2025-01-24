alias ll="ls -l"

alias gll="git fetch && git pull"
alias gf="git fetch"
alias gc="git checkout"


function _logargs() { 
  if [ -p /dev/stdin ]; then
    while IFS= read -r arg; do
      echo "Argument: $arg" >> ~/args.log
    done
  else
    echo "Arguments: $@" >> ~/args.log
  fi
}
alias logargs='_logargs'


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
      ffmpeg -i "$file" -vf "scale=320:-1:flags=lanczos,fps=10" -gifflags +transdiff -y "${file%.*}.gif"
    done
  else
    for file in "$@"; do
      ffmpeg -i "$file" -vf "scale=320:-1:flags=lanczos,fps=10" -gifflags +transdiff -y "${file%.*}.gif"
    done
  fi
}
alias togif='_togif'


eval "$(zoxide init bash)"
