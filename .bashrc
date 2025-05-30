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
  local replace=false
  if [ "$1" == "-r" ]; then
    replace=true
    shift
  fi

  if [ -p /dev/stdin ]; then
    while IFS= read -r file; do
      if [ "$replace" = true ]; then
        ffmpeg -i "$file" -vcodec libx264 -crf 23 "${file%.*}-compressed.${file##*.}" && mv "${file%.*}-compressed.${file##*.}" "$file"
      else
        ffmpeg -i "$file" -vcodec libx264 -crf 23 "${file%.*}-compressed.${file##*.}"
      fi
    done
  else
    for file in "$@"; do 
      if [ "$replace" = true ]; then
        ffmpeg -i "$file" -vcodec libx264 -crf 23 "${file%.*}-compressed.${file##*.}" && mv "${file%.*}-compressed.${file##*.}" "$file"
      else
        ffmpeg -i "$file" -vcodec libx264 -crf 23 "${file%.*}-compressed.${file##*.}"
      fi
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

alias ncu='npx npm-check-updates -i'


eval "$(zoxide init bash)"


### Extract files from failed log bat 0_build.txt | rg FAIL | rg -o -r '$0' '\b[a-zA-Z0-9_/.-]+\.[a-zA-Z]+\b' |sort | uniq  | tr '\n' ' '