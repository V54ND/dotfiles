## Index

* [__history_sync](#__history_sync)
* [__history_install_prompt_command](#__history_install_prompt_command)

### __history_sync

Writes the current session history to disk and imports new history from other sessions.

#### Example

```bash
__history_sync
```

#### Exit codes

* **0**: History was synced successfully.

### __history_install_prompt_command

Adds the history sync hook to PROMPT_COMMAND unless it is already installed.

#### Example

```bash
__history_install_prompt_command
```

#### Exit codes

* **0**: The hook was installed or was already present.

