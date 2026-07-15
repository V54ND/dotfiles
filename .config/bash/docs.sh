# shellcheck shell=bash

__bash_docs_source="${BASH_SOURCE[0]}"
__bash_docs_dir="$(cd -- "$(dirname -- "$__bash_docs_source")" && pwd -P)" || __bash_docs_dir=""
unset __bash_docs_source

# @description
# Generates Markdown documentation for documented Bash functions under this config directory.
#
# @example
#   bash_docs
#
# @stdout A summary with the generated documentation directory.
# @stderr Missing shdoc, directory preparation failures, and per-file generation errors.
#
# @exitcode 0 Documentation was generated successfully.
# @exitcode 1 shdoc was missing, the docs directory could not be prepared, or a file failed to generate.
bash_docs() {
  if ! command -v shdoc >/dev/null 2>&1; then
    echo "Error: 'shdoc' is required for bash_docs" >&2
    return 1
  fi

  if [ -z "$__bash_docs_dir" ] || [ ! -d "$__bash_docs_dir" ]; then
    echo "Error: Could not determine the Bash config directory" >&2
    return 1
  fi

  local generated_dir="$__bash_docs_dir/docs/generated"
  local file rel_path output_path output_dir tmp_output
  local had_error=0

  mkdir -p -- "$generated_dir" || return 1
  find "$generated_dir" -type f -name '*.md' -delete

  while IFS= read -r -d '' file; do
    grep -q '^[[:space:]]*# @description' "$file" || continue

    rel_path="${file#"$__bash_docs_dir"/}"
    output_path="$generated_dir/${rel_path%.*}.md"
    output_dir="$(dirname -- "$output_path")"
    tmp_output="$output_path.tmp"

    if ! mkdir -p -- "$output_dir"; then
      had_error=1
      continue
    fi

    if shdoc <"$file" >"$tmp_output"; then
      if [ -s "$tmp_output" ]; then
        mv -- "$tmp_output" "$output_path"
      else
        rm -f -- "$tmp_output"
      fi
    else
      echo "Error: Failed to generate docs for $file" >&2
      rm -f -- "$tmp_output"
      had_error=1
    fi
  done < <(
    find "$__bash_docs_dir" \
      -path "$generated_dir" -prune -o \
      -type f \( -name '*.bash' -o -name '*.sh' \) -print0
  )

  find "$generated_dir" -mindepth 1 -depth -type d -empty -delete

  if [ "$had_error" -ne 0 ]; then
    return "$had_error"
  fi

  printf 'Generated Bash docs in %s\n' "$generated_dir"
}

# @description
# Opens generated Bash function documentation with glow, bat, or less.
#
# @example
#   bash_docs_view
#
# @stdout Rendered Markdown output or a message suggesting bash_docs when no generated docs exist.
# @stderr Viewer errors and missing documentation messages.
#
# @exitcode 0 Documentation was opened successfully.
# @exitcode 1 Generated documentation does not exist or the selected viewer failed.
bash_docs_view() {
  if [ -z "$__bash_docs_dir" ] || [ ! -d "$__bash_docs_dir" ]; then
    echo "Error: Could not determine the Bash config directory" >&2
    return 1
  fi

  local generated_dir="$__bash_docs_dir/docs/generated"
  local doc_file
  local docs=()

  if [ ! -d "$generated_dir" ]; then
    echo "No generated Bash docs found. Run bash_docs first." >&2
    return 1
  fi

  while IFS= read -r -d '' doc_file; do
    docs+=("$doc_file")
  done < <(find "$generated_dir" -type f -name '*.md' -print0 | sort -z)

  if [ "${#docs[@]}" -eq 0 ]; then
    echo "No generated Bash docs found. Run bash_docs first." >&2
    return 1
  fi

  if command -v glow >/dev/null 2>&1; then
    for doc_file in "${docs[@]}"; do
      glow "$doc_file" || return 1
    done
  elif command -v bat >/dev/null 2>&1; then
    bat --language markdown "${docs[@]}"
  else
    less "${docs[@]}"
  fi
}
