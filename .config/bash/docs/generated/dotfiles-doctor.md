## Index

* [ok](#ok)
* [warn](#warn)
* [fail](#fail)
* [check_command](#check_command)
* [check_optional_command](#check_optional_command)

### ok

Prints a successful doctor check, using terminal colors when available.

#### Arguments

* **$1** (string): Human-readable check name.

#### Exit codes

* **0**: The message was printed.

#### Output on stdout

* One formatted success line.

### warn

Records and prints a non-fatal doctor warning.

#### Arguments

* **$1** (string): Human-readable warning message.

#### Exit codes

* **0**: The warning was recorded and printed.

#### Output on stdout

* One formatted warning line.

### fail

Records and prints a failed doctor check.

#### Arguments

* **$1** (string): Human-readable failure message.

#### Exit codes

* **0**: The failure was recorded and printed.

#### Output on stdout

* One formatted failure line.

### check_command

Checks whether a required command is available on PATH.

#### Arguments

* **$1** (string): Command name to check.

#### Exit codes

* **0**: The command was found.
* **1**: The command was missing.

#### Output on stdout

* A success or failure line.

### check_optional_command

Checks whether an optional command is available on PATH.

#### Arguments

* **$1** (string): Optional command name to check.

#### Exit codes

* **0**: The check completed; a missing command is reported as a warning.

#### Output on stdout

* A success or warning line.

