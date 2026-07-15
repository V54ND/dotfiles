## Index

* [_compress_human_size](#_compress_human_size)
* [_compress_read_stdin](#_compress_read_stdin)
* [_compress_process_file](#_compress_process_file)
* [_compress_run_queue](#_compress_run_queue)
* [_compress](#_compress)
* [_logpipe](#_logpipe)
* [extract_failed](#extract_failed)
* [mkcd](#mkcd)

### _compress_human_size

Formats a byte count with numfmt when available and falls back to a plain byte label.

#### Example

```bash
_compress_human_size 1048576
```

#### Arguments

* **$1** (integer): Byte count to format.

#### Exit codes

* **0**: The size was printed.

#### Output on stdout

* The formatted size.

### _compress_read_stdin

Reads file paths from stdin, removes trailing carriage returns, and skips empty lines.

#### Example

```bash
printf '%s\r\n' video.mp4 | _compress_read_stdin
```

#### Exit codes

* **0**: Input was consumed successfully.

#### Output on stdout

* Normalized non-empty input lines.

### _compress_process_file

Compresses one supported video file with ffmpeg and optionally replaces the original file.

#### Example

```bash
_compress_process_file video.mp4 false 23 fast false
```

#### Arguments

* **$1** (string): Video file to compress.
* **$2** (boolean): Whether to replace the original file.
* **$3** (integer): ffmpeg CRF quality value.
* **$4** (string): ffmpeg encoder preset.
* **$5** (boolean): Whether to suppress ffmpeg output.

#### Exit codes

* **0**: The file was compressed successfully.
* **1**: The file was missing, unsupported, or skipped.

#### Output on stdout

* Progress and size reduction messages.

#### Output on stderr

* Warnings for missing files, unsupported formats, and failed compression.

### _compress_run_queue

Runs video compression for one or more files, optionally scheduling several jobs in parallel.

#### Example

```bash
_compress_run_queue false 23 fast false 2 video.mp4 clip.mov
```

#### Arguments

* **$1** (boolean): Whether to replace original files.
* **$2** (integer): ffmpeg CRF quality value.
* **$3** (string): ffmpeg encoder preset.
* **$4** (boolean): Whether to suppress ffmpeg output.
* **$5** (integer): Number of parallel jobs to run.
* **...** (string): Video files to process after the first five arguments.

#### Exit codes

* **0**: All files were processed successfully.
* **1**: At least one file failed or was skipped.

#### Output on stdout

* Queue progress and per-file compression messages.

#### Output on stderr

* Per-file warnings and compression errors.

### _compress

Compresses video files passed as arguments or through stdin using ffmpeg.

#### Example

```bash
compress video.mp4
compress -r -q 20 *.mp4
find . -type f -name '*.mov' | compress -j 4
```

#### Arguments

* **...** (string): Options and file paths accepted by compress.

#### Exit codes

* **0**: Help was shown or all files were compressed successfully.
* **1**: Options were invalid, ffmpeg was missing, no files were provided, or a file failed.

#### Output on stdout

* Usage text, progress messages, and compression summaries.

#### Output on stderr

* Invalid options, missing tools, and per-file warnings.

### _logpipe

Displays piped input as a trimmed list, with optional numbering, prefixing, and passthrough output.

#### Example

```bash
find . -name '*.txt' | logpipe -n
ls | logpipe -t | compress
```

#### Arguments

* **...** (string): Options accepted by logpipe.

#### Exit codes

* **0**: Input was displayed or help was shown successfully.
* **1**: An option was invalid or no piped input was provided.

#### Output on stdout

* Formatted input, passthrough input, usage text, or help text depending on options and pipeline state.

#### Output on stderr

* Formatted input when passthrough output is enabled.

### extract_failed

Extracts unique TypeScript and TSX file paths from FAIL lines in a text file.

#### Example

```bash
extract-failed test-output.log
```

#### Arguments

* **$1** (string): File to scan for failed test entries.

#### Exit codes

* **0**: Matching paths were extracted successfully.
* **1**: The input file was missing, not found, or rg was unavailable.

#### Output on stdout

* Matching .ts and .tsx paths, or usage and file errors for invalid input.

#### Output on stderr

* Prints an error when rg is not available.

### mkcd

Creates a directory and changes the current shell into it.

#### Example

```bash
mkcd scratch/new-project
```

#### Arguments

* **$1** (string): Directory path to create and enter.

#### Exit codes

* **0**: The directory was created and entered.
* **1**: No directory was provided, mkdir failed, or cd failed.

#### Output on stderr

* Prints usage text when no directory is provided.

