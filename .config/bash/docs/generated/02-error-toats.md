## Index

* [__prompt_error_status](#__prompt_error_status)
* [errors](#errors)

### __prompt_error_status

Records the previous failed command and prints a ble.sh-style status line.
Starship calls this function immediately before rendering the next prompt.

#### Exit codes

* **0**: The status was ignored, recorded, or already recorded for this prompt cycle.

#### Output on stdout

* A red failure status line when the previous command failed.

#### Output on stderr

* Filesystem errors while creating or writing the error log.

### errors

Displays recent failed commands recorded by the prompt status hook.

#### Example

```bash
errors
errors 100
```

#### Arguments

* **$1** (integer): Number of entries to show; defaults to 30.

#### Exit codes

* **0**: The log was displayed or is empty.

#### Output on stdout

* Recent timestamped command failures, or a message when the log is empty.

