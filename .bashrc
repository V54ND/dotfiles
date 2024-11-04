alias ll="ls -l"

alias gf="git fetch"
alias gl="git pull"

alias compress='function _compress(){ ffmpeg -i "$1" -vcodec libx264 -crf 23 "${1%.*}-compressed.${1##*.}"; }; _compress'

alias video_to_gif='function _video_to_gif(){ ffmpeg -i "$1" -vf "fps=10,scale=720:-1:flags=lanczos" -c:v gif "${1%.*}.gif"; }; _video_to_gif'

alias video_to_gif_batch='function _video_to_gif(){ 
  if [ -z "$1" ]; then 
    echo "No argument supplied. Please provide a string to match files."; 
    return 1; 
  fi; 
  for file in *"$1"*; do 
    if [ -f "$file" ]; then 
      filename="${file%.*}"; 
      ffmpeg -i "$file" -vf "fps=10,scale=720:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -loop 0 "${filename}.gif"; 
    fi; 
  done; 
}; _video_to_gif'

eval "$(zoxide init bash)"
