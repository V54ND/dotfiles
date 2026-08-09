# shellcheck shell=bash

# @description
# Compresses video from any input format to H.264 MP4 using single-pass, constant-quality encoding.
#
# @arg $@ string Options and video paths. Newline-delimited paths are also accepted from stdin.
#
# @example
#   compress video.mp4 clip.mov recording.mkv
# @example
#   rg --files -g '*.mp4' -g '*.mov' -g '*.mkv' | compress
# @example
#   compress --quality 26 --preset medium video.webm
#
# @stdout Progress, size reduction, and output file paths.
# @stderr Invalid options, missing dependencies, skipped files, and ffmpeg errors.
#
# @exitcode 0 Every video was compressed successfully.
# @exitcode 1 An option was invalid, a dependency was missing, no files were supplied, or at least one input failed.
compress() {
  local quality="${COMPRESS_CRF:-30}"
  local preset="${COMPRESS_PRESET:-fast}"
  local file output
  local directory basename stem
  local original_size compressed_size reduction
  local failed=0
  local files=()

  while [ "$#" -gt 0 ]; do
    case "$1" in
      -q|--quality)
        if [ "$#" -lt 2 ]; then
          echo "Error: --quality requires a CRF value" >&2
          return 1
        fi
        quality="$2"
        shift 2
        ;;
      -p|--preset)
        if [ "$#" -lt 2 ]; then
          echo "Error: --preset requires a value" >&2
          return 1
        fi
        preset="$2"
        shift 2
        ;;
      -h|--help)
        printf '%s\n' \
          "Usage: compress [OPTIONS] [FILE...]" \
          "" \
          "Compresses videos from any input format to H.264 MP4." \
          "Single-pass CRF encoding balances quality, size, and speed." \
          "Paths may be passed as arguments or one per line through stdin." \
          "" \
          "Options:" \
          "  -q, --quality CRF   Quality from 0-51 (default: 51; higher is smaller)" \
          "  -p, --preset NAME   x264 preset (default: fast; faster presets encode faster)" \
          "  -h, --help          Show this help" \
          "" \
          "Environment: COMPRESS_CRF and COMPRESS_PRESET override defaults." \
          "Output: <input-name>-compressed.mp4; source files are never replaced." \
          "The first audio stream is encoded as AAC; other streams are omitted."
        return 0
        ;;
      --)
        shift
        files+=("$@")
        break
        ;;
      -*)
        echo "Error: Unknown option: $1" >&2
        return 1
        ;;
      *)
        files+=("$1")
        shift
        ;;
    esac
  done

  if [[ ! "$quality" =~ ^[0-9]+$ ]] || [ "$((10#$quality))" -gt 51 ]; then
    echo "Error: Quality must be a number between 0 and 51" >&2
    return 1
  fi
  quality="$((10#$quality))"

  case "$preset" in
    ultrafast|superfast|veryfast|faster|fast|medium|slow|slower|veryslow) ;;
    *)
      echo "Error: Invalid preset: $preset" >&2
      echo "Use: ultrafast, superfast, veryfast, faster, fast, medium, slow, slower, veryslow" >&2
      return 1
      ;;
  esac

  if ! command -v ffmpeg >/dev/null 2>&1 || ! command -v ffprobe >/dev/null 2>&1; then
    echo "Error: ffmpeg and ffprobe are required for compress" >&2
    return 1
  fi

  if ! ffmpeg -hide_banner -encoders 2>&1 | grep -q '[[:space:]]libx264[[:space:]]'; then
    echo "Error: This ffmpeg build does not include libx264" >&2
    return 1
  fi

  if [ ! -t 0 ]; then
    while IFS= read -r file || [ -n "$file" ]; do
      file="${file%$'\r'}"
      [ -n "$file" ] && files+=("$file")
    done
  fi

  if [ "${#files[@]}" -eq 0 ]; then
    echo "Usage: compress [OPTIONS] [FILE...] or command | compress" >&2
    return 1
  fi

  for file in "${files[@]}"; do
    if [ ! -f "$file" ]; then
      echo "Warning: '$file' is not a file, skipping" >&2
      failed=1
      continue
    fi

    if ! ffprobe -v error -select_streams v:0 -show_entries stream=index -of csv=p=0 -- "$file" |
      grep -q .; then
      echo "Warning: '$file' has no video stream, skipping" >&2
      failed=1
      continue
    fi

    if [[ "$file" == */* ]]; then
      directory="${file%/*}/"
    else
      directory=""
    fi
    basename="${file##*/}"
    stem="${basename%.*}"
    [ -n "$stem" ] || stem="$basename"
    output="${directory}${stem}-compressed.mp4"

    if [ -e "$output" ]; then
      echo "Warning: '$output' already exists, skipping" >&2
      failed=1
      continue
    fi

    original_size=$(wc -c <"$file" 2>/dev/null)
    original_size="${original_size//[[:space:]]/}"

    printf 'Compressing: %s -> %s (H.264 CRF %s, preset %s)\n' \
      "$file" "$output" "$quality" "$preset"

    if command ffmpeg \
      -hide_banner \
      -nostdin \
      -n \
      -i "$file" \
      -map '0:v:0' \
      -map '0:a:0?' \
      -map_metadata 0 \
      -map_chapters 0 \
      -c:v libx264 \
      -preset "$preset" \
      -crf "$quality" \
      -pix_fmt yuv420p \
      -c:a aac \
      -b:a 128k \
      -movflags +faststart \
      "$output"; then
      compressed_size=$(wc -c <"$output" 2>/dev/null)
      compressed_size="${compressed_size//[[:space:]]/}"

      if [[ "$original_size" =~ ^[0-9]+$ ]] &&
        [[ "$compressed_size" =~ ^[0-9]+$ ]] && [ "$original_size" -gt 0 ]; then
        reduction=$(((original_size - compressed_size) * 100 / original_size))
        printf 'Created: %s (%s%% size reduction)\n' "$output" "$reduction"
      else
        printf 'Created: %s\n' "$output"
      fi
    else
      rm -f -- "$output"
      failed=1
    fi
  done

  return "$failed"
}

# @description
# Displays piped input as a trimmed list, with optional numbering, prefixing, and passthrough output.
#
# @arg $@ string Options accepted by logpipe.
#
# @example
#   find . -name '*.txt' | logpipe -n
# @example
#   ls | logpipe -t | compress
#
# @stdout Formatted input, passthrough input, usage text, or help text depending on options and pipeline state.
# @stderr Formatted input when passthrough output is enabled.
#
# @exitcode 0 Input was displayed or help was shown successfully.
# @exitcode 1 An option was invalid or no piped input was provided.
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

# @description
# Extracts unique TypeScript and TSX file paths from FAIL lines in a text file.
#
# @arg $1 string File to scan for failed test entries.
#
# @example
#   extract-failed test-output.log
#
# @stdout Matching .ts and .tsx paths, or usage and file errors for invalid input.
# @stderr Prints an error when rg is not available.
#
# @exitcode 0 Matching paths were extracted successfully.
# @exitcode 1 The input file was missing, not found, or rg was unavailable.
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

# @description
# Creates a directory and changes the current shell into it.
#
# @arg $1 string Directory path to create and enter.
#
# @example
#   mkcd scratch/new-project
#
# @stderr Prints usage text when no directory is provided.
#
# @exitcode 0 The directory was created and entered.
# @exitcode 1 No directory was provided, mkdir failed, or cd failed.
mkcd() {
  if [ -z "$1" ]; then
    echo "Usage: mkcd <directory>" >&2
    return 1
  fi

  mkdir -p -- "$1" && cd -- "$1" || return 1
}
