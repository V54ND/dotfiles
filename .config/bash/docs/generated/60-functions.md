## Index

* [compress](#compress)
* [_logpipe](#_logpipe)
* [extract_failed](#extract_failed)
* [mkcd](#mkcd)

### compress

Re-encodes video to high-quality 10-bit AV1 with SVT-AV1 while copying audio, subtitles, attachments, and metadata.

#### Example

```bash
compress video.mp4 clip.mov
ls | grep -Ei '\.(mp4|mov|mkv)$' | compress
compress --quality 20 --preset 6 video.mp4
```

#### Arguments

* **...** (string): Options and video paths. Newline-delimited paths are also accepted from stdin.

#### Exit codes

* **0**: Every video was encoded successfully.
* **1**: An option was invalid, a dependency was missing, no files were supplied, or at least one file failed.

#### Output on stdout

* Progress and output file paths.

#### Output on stderr

* Invalid options, missing dependencies, skipped files, and ffmpeg errors.

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

