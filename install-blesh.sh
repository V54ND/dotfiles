#!/usr/bin/env bash
# shellcheck shell=bash

set -euo pipefail

blesh_url="${BLESH_URL:-https://github.com/akinomyoga/ble.sh/releases/download/nightly/ble-nightly.tar.xz}"
install_root="${XDG_DATA_HOME:-$HOME/.local/share}"
case "$install_root" in
  [[:alpha:]]:[\\/]*)
    if ! command -v cygpath >/dev/null 2>&1; then
      printf 'install-blesh: cygpath is required for Windows-style XDG paths\n' >&2
      exit 1
    fi
    install_root=$(cygpath -u "$install_root")
    ;;
esac
install_file="$install_root/blesh/ble.sh"

for command_name in curl tar xz mktemp; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    printf 'install-blesh: missing required command: %s\n' "$command_name" >&2
    exit 1
  fi
done

temp_dir=$(mktemp -d)
trap 'rm -rf "$temp_dir"' EXIT

printf 'Downloading ble.sh nightly...\n'
curl --fail --location --retry 3 --proto '=https' --tlsv1.2 \
  "$blesh_url" -o "$temp_dir/ble-nightly.tar.xz"

tar -xJf "$temp_dir/ble-nightly.tar.xz" -C "$temp_dir"
bash "$temp_dir/ble-nightly/ble.sh" --install "$install_root"

if [ ! -r "$install_file" ]; then
  printf 'install-blesh: installation did not create %s\n' "$install_file" >&2
  exit 1
fi

printf 'ble.sh installed at %s\n' "$install_file"
printf 'Restart Git Bash, then run: dotfiles-doctor\n'
