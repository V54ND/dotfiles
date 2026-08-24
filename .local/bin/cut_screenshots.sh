#!/usr/bin/env bash

set -Eeuo pipefail

# Интервал между скриншотами в секундах.
STEP_SECONDS="${STEP_SECONDS:-60}"

if ! [[ "$STEP_SECONDS" =~ ^[1-9][0-9]*$ ]]; then
    echo "Ошибка: STEP_SECONDS должен быть положительным целым числом." >&2
    exit 1
fi

if [[ $# -ne 1 ]]; then
    echo "Использование: $0 путь/к/видео.mp4" >&2
    exit 1
fi

input=$1

if [[ ! -f "$input" ]]; then
    echo "Ошибка: файл не найден: $input" >&2
    exit 1
fi

if ! command -v ffmpeg >/dev/null 2>&1 || ! command -v ffprobe >/dev/null 2>&1; then
    echo "Ошибка: нужны ffmpeg и ffprobe." >&2
    exit 1
fi

directory=$(dirname -- "$input")
filename=$(basename -- "$input")
name=${filename%.*}
output_dir="$directory/$name"

mkdir -p -- "$output_dir"

duration=$(ffprobe -v error -show_entries format=duration \
    -of default=noprint_wrappers=1:nokey=1 -- "$input")

if [[ -z "$duration" ]]; then
    echo "Ошибка: не удалось определить длительность видео." >&2
    exit 1
fi

duration_seconds=${duration%.*}
total=$((duration_seconds / STEP_SECONDS + 1))
current=0

progress() {
    local percent=$((current * 100 / total))
    local filled=$((percent / 2))
    local empty=$((50 - filled))
    printf '\rПрогресс: [%*s%*s] %3d%% (%d/%d)' \
        "$filled" '' "$empty" '' "$percent" "$current" "$total"
}

for ((seconds=0; seconds<=duration_seconds; seconds+=STEP_SECONDS)); do
    hours=$((seconds / 3600))
    minutes=$(((seconds % 3600) / 60))
    secs=$((seconds % 60))
    timestamp=$(printf '%02d-%02d-%02d' "$hours" "$minutes" "$secs")
    output="$output_dir/screenshot_${timestamp}.jpg"

    if [[ -z "${output//[[:space:]]/}" ]]; then
        echo "Ошибка: пустой путь для выходного файла." >&2
        exit 1
    fi

    ffmpeg -hide_banner -loglevel error -y -fflags +discardcorrupt -err_detect ignore_err -ss "$seconds" -i "$input" -map 0:v:0 -an -sn -dn -vf 'scale=in_range=auto:out_range=full:flags=lanczos,format=yuvj420p' -frames:v 1 -q:v 2 -f image2 "$output"

    current=$((current + 1))
    progress
done

printf '\nГотово. Скриншоты сохранены в: %s\n' "$output_dir"
