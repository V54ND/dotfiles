# shellcheck shell=bash

_compress_human_size() {
  if command -v numfmt >/dev/null 2>&1; then
    numfmt --to=iec "$1"
  else
    printf '%s bytes' "$1"
  fi
}

_compress_read_stdin() {
  local line
  while IFS= read -r line || [ -n "$line" ]; do
    line="${line%$'\r'}"
    [ -n "$line" ] && printf '%s\n' "$line"
  done
}

_compress_process_file() {
  local file="$1"
  local replace="$2"
  local quality="$3"
  local preset="$4"
  local quiet="$5"
  local extension original_size basename output_file compressed_size reduction
  local ffmpeg_status=0
  local ffmpeg_cmd

  if [ ! -f "$file" ]; then
    echo "Warning: File '$file' does not exist, skipping..." >&2
    return 1
  fi

  extension="${file##*.}"
  case "${extension,,}" in
    mp4|avi|mov|mkv|wmv|flv|webm|m4v) ;;
    *)
      echo "Warning: '$file' is not a supported video format, skipping..." >&2
      return 1
      ;;
  esac

  basename="${file%.*}"
  output_file="${basename}-compressed.${extension}"
  if [ -f "$output_file" ] && [ "$replace" = false ]; then
    echo "Warning: '$output_file' already exists, skipping..." >&2
    return 1
  fi

  original_size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "unknown")
  ffmpeg_cmd=(ffmpeg -nostdin -y -i "$file" -c:v libx264 -crf "$quality" -preset "$preset")
  if [ "$quiet" = true ]; then
    ffmpeg_cmd+=(-loglevel error)
  fi
  ffmpeg_cmd+=("$output_file")

  if [ "$replace" = true ]; then
    echo "Compressing and replacing: $file (quality: $quality, preset: $preset)"
  else
    echo "Compressing: $file -> $output_file (quality: $quality, preset: $preset)"
  fi

  "${ffmpeg_cmd[@]}"
  ffmpeg_status=$?
  if [ "$ffmpeg_status" -ne 0 ]; then
    echo "Compression failed for: $file" >&2
    return "$ffmpeg_status"
  fi

  if [ "$original_size" != "unknown" ] && [ -f "$output_file" ]; then
    compressed_size=$(stat -f%z "$output_file" 2>/dev/null || stat -c%s "$output_file" 2>/dev/null || echo "unknown")
    if [ "$compressed_size" != "unknown" ] && [ "$original_size" -gt 0 ]; then
      reduction=$(((original_size - compressed_size) * 100 / original_size))
      echo "Compression completed: ${reduction}% size reduction ($(_compress_human_size "$original_size") -> $(_compress_human_size "$compressed_size"))"
    fi
  fi

  if [ "$replace" = true ]; then
    mv -- "$output_file" "$file"
    echo "Original file replaced"
  fi
}

_compress_run_queue() {
  local replace="$1"
  local quality="$2"
  local preset="$3"
  local quiet="$4"
  local parallel_jobs="$5"
  shift 5

  local file
  local failed=0
  local job_count
  local pid
  local pids=()
  if [ "$parallel_jobs" -le 1 ] || [ "$#" -le 1 ]; then
    for file in "$@"; do
      if ! _compress_process_file "$file" "$replace" "$quality" "$preset" "$quiet"; then
        failed=1
      fi
    done
    return "$failed"
  fi

  echo "Processing $# files with $parallel_jobs parallel jobs..."
  for file in "$@"; do
    while :; do
      job_count=$(jobs -pr | wc -l | tr -d '[:space:]')
      [ -z "$job_count" ] && job_count=0
      [ "$job_count" -lt "$parallel_jobs" ] && break
      sleep 0.1
    done
    _compress_process_file "$file" "$replace" "$quality" "$preset" "$quiet" &
    pids+=("$!")
  done

  for pid in "${pids[@]}"; do
    if ! wait "$pid"; then
      failed=1
    fi
  done

  return "$failed"
}

_compress() {
  local replace=false
  local quality=23
  local preset="fast"
  local quiet=false
  local parallel_jobs=1
  local file
  local files_array=()

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
        echo "  -p, --preset PRESET    Set encoding preset (default: fast)"
        echo "  -s, --silent           Suppress ffmpeg output"
        echo "  -j, --jobs NUM         Number of parallel jobs (default: 1)"
        echo "  -h, --help             Show this help"
        echo ""
        echo "Examples:"
        echo "  compress video.mp4"
        echo "  compress -r -q 20 *.mp4"
        echo "  ls -1 | rg '\\.(mp4|mov)$' | compress -p fast"
        echo "  find . -type f -name '*.mov' | compress -j 4"
        return 0
        ;;
      *)
        echo "Unknown option: $1" >&2
        return 1
        ;;
    esac
  done

  if ! command -v ffmpeg >/dev/null 2>&1; then
    echo "Error: 'ffmpeg' is required for compress" >&2
    return 1
  fi

  if [ ! -t 0 ]; then
    while IFS= read -r file; do
      files_array+=("$file")
    done < <(_compress_read_stdin)
  fi

  if [ "$#" -gt 0 ]; then
    files_array+=("$@")
  fi

  if [ "${#files_array[@]}" -eq 0 ]; then
    echo "Usage: compress [OPTIONS] <files...> or command | compress [OPTIONS]"
    echo "Use 'compress --help' for more information"
    return 1
  fi

  _compress_run_queue "$replace" "$quality" "$preset" "$quiet" "$parallel_jobs" "${files_array[@]}"
}

alias compress='_compress'

_logpipe() {
  local counter=1
  local show_numbers=false
  local prefix=""
  local passthrough=false
  local temp_array=()

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
        echo "  ls | logpipe -t | compress"
        echo "  ps aux | logpipe -p 'Process:'"
        return 0
        ;;
      *)
        echo "Unknown option: $1" >&2
        return 1
        ;;
    esac
  done

  if [ -p /dev/stdin ] || [ ! -t 0 ]; then
    if [ "$passthrough" = true ] || [ ! -t 1 ]; then
      while IFS= read -r line; do
        line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        [ -n "$line" ] && temp_array+=("$line")
      done

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

      for line in "${temp_array[@]}"; do
        echo "$line"
      done
    else
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

extract_failed() {
  if [ -z "$1" ]; then
    echo "Usage: extract-failed <filename>"
    return 1
  fi

  if [ ! -f "$1" ]; then
    echo "Error: File '$1' not found"
    return 1
  fi

  if ! command -v rg >/dev/null 2>&1; then
    echo "Error: 'rg' is required for extract-failed" >&2
    return 1
  fi

  rg "FAIL" -- "$1" | rg -o '[^[:space:]]+\.(tsx|ts)$' | sort -u
}

alias extract-failed='extract_failed'

mkcd() {
  if [ -z "$1" ]; then
    echo "Usage: mkcd <directory>" >&2
    return 1
  fi

  mkdir -p -- "$1" && cd -- "$1" || return 1
}
