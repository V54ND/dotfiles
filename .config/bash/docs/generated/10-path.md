## Index

* [_path_prepend](#_path_prepend)

### _path_prepend

Prepends an existing directory to PATH when it is not already present.

#### Example

```bash
_path_prepend "$HOME/.local/bin"
```

#### Arguments

* **$1** (string): Directory path to add to the front of PATH.

#### Exit codes

* **0**: The directory was added, was already present, or was skipped.

