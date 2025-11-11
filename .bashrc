# =============================================================================
# EZA ALIASES (modern ls replacement)
# =============================================================================
alias l='eza --color=always --color-scale=all --color-scale-mode=gradient --icons=always --group-directories-first'
alias ll='eza --color=always --color-scale=all --color-scale-mode=gradient --icons=always --group-directories-first -l --git -h'
alias la='eza --color=always --color-scale=all --color-scale-mode=gradient --icons=always --group-directories-first -a'
alias lla='eza --color=always --color-scale=all --color-scale-mode=gradient --icons=always --group-directories-first -a -l --git -h'

# =============================================================================
# GIT ALIASES
# =============================================================================

alias gll="git fetch && git pull"
alias gf="git fetch"
alias gc="git checkout"
alias gp="git push -u origin \$(git branch --show-current)"
alias gs="git status"
alias ga="git add"
alias gaa="git add --all"
alias gcm="git commit -m"
alias gca="git commit --amend"
alias gd="git diff"
alias gds="git diff --staged"
alias gl="git log --oneline -10"
alias gb="git branch"
alias gbd="git branch -d"
alias gco="git checkout"
alias gcb="git checkout -b"

# =============================================================================
# VIDEO COMPRESSION FUNCTION
# =============================================================================
function _compress() { 
  local replace=false
  local quality=23
  local preset="medium"
  local quiet=false
  local parallel_jobs=1
  local video_formats="mp4|avi|mov|mkv|wmv|flv|webm|m4v"
  
  # Обработка опций
  while [[ $1 == -* ]]; do
    case $1 in
      -r|--replace)
        replace=true
        shift
        ;;
      -q|--quality)
        quality="$2"
        if ! [[ "$quality" =~ ^[0-9]+$ ]] || [ "$quality" -lt 0 ] || [ "$quality" -gt 51 ]; then
          echo "Error: Quality must be a number between 0-51" >&2
          return 1
        fi
        shift 2
        ;;
      -p|--preset)
        preset="$2"
        if ! [[ "$preset" =~ ^(ultrafast|superfast|veryfast|faster|fast|medium|slow|slower|veryslow)$ ]]; then
          echo "Error: Invalid preset. Use: ultrafast, superfast, veryfast, faster, fast, medium, slow, slower, veryslow" >&2
          return 1
        fi
        shift 2
        ;;
      -s|--silent)
        quiet=true
        shift
        ;;
      -j|--jobs)
        parallel_jobs="$2"
        if ! [[ "$parallel_jobs" =~ ^[0-9]+$ ]] || [ "$parallel_jobs" -lt 1 ]; then
          echo "Error: Jobs must be a positive number" >&2
          return 1
        fi
        shift 2
        ;;
      -h|--help)
        echo "Usage: compress [OPTIONS] <files...> or command | compress [OPTIONS]"
        echo "Options:"
        echo "  -r, --replace          Replace original files with compressed versions"
        echo "  -q, --quality NUM      Set quality (0-51, lower = better quality, default: 23)"
        echo "  -p, --preset PRESET    Set encoding preset (default: medium)"
        echo "  -s, --silent           Suppress ffmpeg output"
        echo "  -j, --jobs NUM         Number of parallel jobs (default: 1)"
        echo "  -h, --help             Show this help"
        echo ""
        echo "Examples:"
        echo "  compress video.mp4                    # Basic compression"
        echo "  compress -r -q 20 *.mp4              # Replace with higher quality"
        echo "  ls *.avi | compress -p fast           # Fast preset via pipe"
        echo "  find . -name '*.mov' | compress -j 4  # Parallel processing"
        return 0
        ;;
      *)
        echo "Unknown option: $1" >&2
        return 1
        ;;
    esac
  done

  # Функция для обработки одного файла
  _process_file() {
    local file="$1"
    local pid_file=""
    
    # Проверяем, что файл существует
    if [ ! -f "$file" ]; then
      echo "Warning: File '$file' does not exist, skipping..." >&2
      return 1
    fi
    
    # Проверяем, что это видео файл
    local extension="${file##*.}"
    if ! [[ "${extension,,}" =~ ^(${video_formats})$ ]]; then
      echo "Warning: '$file' is not a supported video format, skipping..." >&2
      return 1
    fi
    
    # Получаем информацию о размере файла
    local original_size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "unknown")
    
    # Получаем базовое имя без расширения и расширение
    local basename="${file%.*}"
    local output_file="${basename}-compressed.${extension}"
    
    # Проверяем, не существует ли уже сжатый файл
    if [ -f "$output_file" ] && [ "$replace" = false ]; then
      echo "Warning: '$output_file' already exists, skipping..." >&2
      return 1
    fi
    
    # Готовим ffmpeg команду
    local ffmpeg_cmd="ffmpeg -i \"$file\" -vcodec libx264 -crf $quality -preset $preset"
    
    # Добавляем опцию тишины если нужно
    if [ "$quiet" = true ]; then
      ffmpeg_cmd+=" -loglevel error"
    fi
    
    # Добавляем выходной файл
    ffmpeg_cmd+=" \"$output_file\""
    
    if [ "$replace" = true ]; then
      echo "Compressing and replacing: $file (quality: $quality, preset: $preset)"
    else
      echo "Compressing: $file -> $output_file (quality: $quality, preset: $preset)"
    fi
    
    # Выполняем сжатие
    if eval "$ffmpeg_cmd"; then
      # Показываем результат сжатия
      if [ "$original_size" != "unknown" ] && [ -f "$output_file" ]; then
        local compressed_size=$(stat -f%z "$output_file" 2>/dev/null || stat -c%s "$output_file" 2>/dev/null || echo "unknown")
        if [ "$compressed_size" != "unknown" ]; then
          local reduction=$(( (original_size - compressed_size) * 100 / original_size ))
          echo "✓ Compression completed: ${reduction}% size reduction ($(numfmt --to=iec $original_size) → $(numfmt --to=iec $compressed_size))"
        fi
      fi
      
      # Если нужно заменить оригинал
      if [ "$replace" = true ]; then
        mv "$output_file" "$file"
        echo "✓ Original file replaced"
      fi
    else
      echo "✗ Compression failed for: $file" >&2
      return 1
    fi
  }

  # Функция для параллельной обработки
  _process_parallel() {
    local files=("$@")
    local active_jobs=0
    
    for file in "${files[@]}"; do
      # Ждем, если достигли лимита параллельных задач
      while [ $active_jobs -ge $parallel_jobs ]; do
        wait -n  # Ждем завершения любой фоновой задачи
        ((active_jobs--))
      done
      
      # Запускаем обработку в фоне
      _process_file "$file" &
      ((active_jobs++))
    done
    
    # Ждем завершения всех оставшихся задач
    wait
  }

  # Проверяем наличие данных в stdin или аргументов
  if [ -p /dev/stdin ] || [ ! -t 0 ]; then
    # Читаем из stdin (работает с ls | grep | compress)
    local files_array=()
    local IFS=$'\n'
    while read -r file; do
      # Убираем только начальные и конечные пробелы, сохраняя пробелы в названиях
      file=$(echo "$file" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
      [ -n "$file" ] && files_array+=("$file")
    done
    
    if [ ${#files_array[@]} -gt 0 ]; then
      if [ $parallel_jobs -gt 1 ] && [ ${#files_array[@]} -gt 1 ]; then
        echo "Processing ${#files_array[@]} files with $parallel_jobs parallel jobs..."
        _process_parallel "${files_array[@]}"
      else
        for file in "${files_array[@]}"; do
          _process_file "$file"
        done
      fi
    else
      echo "No files to process" >&2
      return 1
    fi
  elif [ $# -gt 0 ]; then
    # Обрабатываем аргументы командной строки
    if [ $parallel_jobs -gt 1 ] && [ $# -gt 1 ]; then
      echo "Processing $# files with $parallel_jobs parallel jobs..."
      _process_parallel "$@"
    else
      for file in "$@"; do 
        _process_file "$file"
      done
    fi
  else
    echo "Usage: compress [OPTIONS] <files...> or command | compress [OPTIONS]"
    echo "Use 'compress --help' for more information"
    return 1
  fi
}

alias compress='_compress'

# =============================================================================
# LOG PIPE FUNCTION (for debugging pipelines)
# =============================================================================
function _logpipe() {
  local counter=1
  local show_numbers=false
  local prefix=""
  local passthrough=false
  local temp_array=()
  
  # Обработка опций
  while [[ $1 == -* ]]; do
    case $1 in
      -n|--numbers)
        show_numbers=true
        shift
        ;;
      -p|--prefix)
        prefix="$2"
        shift 2
        ;;
      -t|--tee)
        passthrough=true
        shift
        ;;
      -h|--help)
        echo "Usage: logpipe [-n|--numbers] [-p|--prefix PREFIX] [-t|--tee] or command | logpipe"
        echo "  -n, --numbers    Show line numbers"
        echo "  -p, --prefix     Add custom prefix to each line"
        echo "  -t, --tee        Pass data through to next command in pipe"
        echo "Examples:"
        echo "  ls | logpipe"
        echo "  find . -name '*.txt' | logpipe -n"
        echo "  ls | logpipe -t | compress    # shows list AND passes to compress"
        echo "  ps aux | logpipe -p 'Process:'"
        return 0
        ;;
      *)
        echo "Unknown option: $1" >&2
        return 1
        ;;
    esac
  done

  # Проверяем наличие данных в stdin
  if [ -p /dev/stdin ] || [ ! -t 0 ]; then
    # Если нужно передавать дальше или если мы не в конце пайпа, читаем в массив
    if [ "$passthrough" = true ] || [ ! -t 1 ]; then
      while IFS= read -r line; do
        # Убираем только начальные и конечные пробелы
        line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        [ -n "$line" ] && temp_array+=("$line")
      done
      
      # Показываем список на stderr, чтобы не мешать пайпу
      echo "=== Pipe Input List ===" >&2
      for line in "${temp_array[@]}"; do
        if [ "$show_numbers" = true ]; then
          printf "%3d. %s%s\n" "$counter" "$prefix" "$line" >&2
          ((counter++))
        else
          echo "- $prefix$line" >&2
        fi
      done
      echo "=== End of List ===" >&2
      
      # Передаем данные дальше по пайпу (в stdout)
      for line in "${temp_array[@]}"; do
        echo "$line"
      done
    else
      # Если мы в конце пайпа, показываем обычный вывод
      echo "=== Pipe Input List ==="
      while IFS= read -r line; do
        line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        
        if [ -n "$line" ]; then
          if [ "$show_numbers" = true ]; then
            printf "%3d. %s%s\n" "$counter" "$prefix" "$line"
            ((counter++))
          else
            echo "- $prefix$line"
          fi
        fi
      done
      echo "=== End of List ==="
    fi
  else
    echo "Usage: command | logpipe [-n] [-p PREFIX] [-t]"
    echo "This function displays piped input as a formatted list"
    return 1
  fi
}
alias logpipe='_logpipe'

# =============================================================================
# NPM & NODE ALIASES
# =============================================================================
alias ncu='npx npm-check-updates -i'

# Улучшенная история команд
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoreboth:erasedups
shopt -s histappend

# Автодополнение для git
if [ -f /usr/share/bash-completion/completions/git ]; then
    source /usr/share/bash-completion/completions/git
fi


# Navigation tool
eval "$(zoxide init bash)"

# =============================================================================
# CUSTOM UTILITIES
# =============================================================================

export OPENAI_API_KEY="$OPENAI_API_KEY" # For windows requires setx OPENAI_API_KEY "your_key"

function extract-failed() {
    if [ -z "$1" ]; then
        echo "Usage: extract-failed <filename>"
        return 1
    fi
    
    if [ ! -f "$1" ]; then
        echo "Error: File '$1' not found"
        return 1
    fi
    
    bat "$1" | rg "FAIL" | rg -o "[^\s]+\.(tsx|ts)?\$" | sort | uniq
}
export AWS_SHARED_CREDENTIALS_FILE=~/.aws/credentials
