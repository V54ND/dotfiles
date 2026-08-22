## Index

* [_xdg_normalize_path](#_xdg_normalize_path)

### _xdg_normalize_path

Converts an inherited Windows-style path to Git Bash format when cygpath is available.

#### Example

```bash
_xdg_normalize_path 'C:\\Users\\me\\.config'
```

#### Arguments

* **$1** (string): Windows-style or already-normalized path.

#### Exit codes

* **0**: The path was printed successfully.

#### Output on stdout

* The normalized path.

