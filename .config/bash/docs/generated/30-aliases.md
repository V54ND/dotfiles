## Index

* [pbcopy](#pbcopy)
* [pbpaste](#pbpaste)

### pbcopy

Copies stdin to the Windows clipboard through clip.exe.

#### Exit codes

* **0**: clip.exe accepted the input.

#### Input on stdin

* Text to copy.

#### Output on stdout

* None.

### pbpaste

Prints the current Windows clipboard contents without PowerShell formatting.

#### Exit codes

* **0**: The clipboard was read successfully.

#### Output on stdout

* Raw clipboard text.

