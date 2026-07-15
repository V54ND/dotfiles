## Index

* [bash_docs](#bash_docs)
* [bash_docs_view](#bash_docs_view)

### bash_docs

Generates Markdown documentation for documented Bash functions under this config directory.

#### Example

```bash
bash_docs
```

#### Exit codes

* **0**: Documentation was generated successfully.
* **1**: shdoc was missing, the docs directory could not be prepared, or a file failed to generate.

#### Output on stdout

* A summary with the generated documentation directory.

#### Output on stderr

* Missing shdoc, directory preparation failures, and per-file generation errors.

### bash_docs_view

Opens generated Bash function documentation with glow, bat, or less.

#### Example

```bash
bash_docs_view
```

#### Exit codes

* **0**: Documentation was opened successfully.
* **1**: Generated documentation does not exist or the selected viewer failed.

#### Output on stdout

* Rendered Markdown output or a message suggesting bash_docs when no generated docs exist.

#### Output on stderr

* Viewer errors and missing documentation messages.

