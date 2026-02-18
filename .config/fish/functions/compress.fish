function compress
    set -l replace 0

    # fixed params как в bash-оригинале
    set -l quality 23
    set -l preset medium

    # parse only -r/--replace
    while test (count $argv) -gt 0
        switch $argv[1]
            case '-r' '--replace'
                set replace 1
                set -e argv[1]
            case '--'
                set -e argv[1]
                break
            case '-*'
                echo "Unknown option: $argv[1]" 1>&2
                echo "Usage: compress [-r|--replace] <files...>" 1>&2
                return 1
            case '*'
                break
        end
    end

    if test (count $argv) -eq 0
        echo "Usage: compress [-r|--replace] <files...>" 1>&2
        return 1
    end

    if not type -q ffmpeg
        echo "Error: ffmpeg not found" 1>&2
        return 1
    end

    for file in $argv
        if not test -f "$file"
            echo "Warning: File '$file' does not exist, skipping..." 1>&2
            continue
        end

        # extension + basename без `path`
        set -l ext (string lower (string split -r -m1 '.' -- "$file")[-1])
        set -l base (string replace -r '\.[^.]+$' '' -- "$file")

        switch $ext
            case mp4 avi mov mkv wmv flv webm m4v
                # ok
            case '*'
                echo "Warning: '$file' is not a supported video format, skipping..." 1>&2
                continue
        end

        set -l output "$base-compressed.$ext"

        if test -f "$output"; and test $replace -eq 0
            echo "Warning: '$output' already exists, skipping..." 1>&2
            continue
        end

        echo "Compressing: $file -> $output (crf: $quality, preset: $preset)"

        # Собираем команду как список аргументов (без eval)
        set -l cmd ffmpeg -y -hide_banner -i "$file" -vcodec libx264 -crf $quality -preset $preset "$output"

        # Печатаем команду (чтобы было видно, что реально запускается)
        echo "CMD: "(string join " " -- $cmd)

        command $cmd
        set -l rc $status

        if test $rc -ne 0
            echo "✗ ffmpeg failed (exit code $rc) for: $file" 1>&2
            return $rc
        end

        if test $replace -eq 1
            mv "$output" "$file"
            echo "✓ Original file replaced"
        end
    end
end
