## Index

* [git_main_branch](#git_main_branch)
* [git_develop_branch](#git_develop_branch)
* [gswm](#gswm)
* [gswd](#gswd)
* [gbs](#gbs)
* [gcbcopy](#gcbcopy)
* [grt](#grt)
* [gup](#gup)
* [gswf](#gswf)

### git_main_branch

Prints the first local default branch found in the current Git repository.

#### Example

```bash
git_main_branch
```

#### Exit codes

* **0**: A default branch was found.
* **1**: The current directory is not a Git repository or no default branch exists.

#### Output on stdout

* The detected branch name.

### git_develop_branch

Prints the first develop-style branch found locally or under origin.

#### Example

```bash
git_develop_branch
```

#### Exit codes

* **0**: A develop-style branch was found.
* **1**: The current directory is not a Git repository or no matching branch exists.

#### Output on stdout

* The detected branch name.

### gswm

Switches the current Git repository to its detected default branch.

#### Example

```bash
gswm
```

#### Exit codes

* **0**: The repository switched to the default branch.
* **1**: The default branch could not be detected or git switch failed.

#### Output on stderr

* Prints an error when the default branch cannot be detected.

### gswd

Switches the current Git repository to its detected develop-style branch.

#### Example

```bash
gswd
```

#### Exit codes

* **0**: The repository switched to the develop-style branch.
* **1**: The develop-style branch could not be detected or git switch failed.

#### Output on stderr

* Prints an error when the develop-style branch cannot be detected.

### gbs

Uses fzf to choose a local Git branch and switches to the selected branch.

#### Example

```bash
gbs
```

#### Exit codes

* **0**: The selected branch was checked out successfully.
* **1**: fzf is missing, no branch was selected, or git switch failed.

#### Output on stderr

* Prints an error when fzf is not available.

### gcbcopy

Copies the current Git branch name to the Windows clipboard.

#### Example

```bash
gcbcopy
```

#### Exit codes

* **0**: The branch name was copied.
* **1**: clip.exe is missing, the branch name could not be detected, or clipboard output failed.

#### Output on stderr

* Prints an error when clip.exe is unavailable or the current branch cannot be detected.

### grt

Changes the current directory to the root of the active Git repository.

#### Example

```bash
grt
```

#### Exit codes

* **0**: The directory was changed to the Git repository root.
* **1**: The repository root could not be detected or cd failed.

### gup

Updates the current Git repository by fetching, pruning, fast-forward pulling, and optionally pulling from the develop-style branch.

#### Example

```bash
gup
```

#### Exit codes

* **0**: The update completed successfully.
* **1**: The current directory is not a Git repository or a Git update command failed.

#### Output on stderr

* Prints an error when the current directory is not a Git repository.

### gswf

Fetches remote branches, lets fzf choose a branch, and switches to the local or tracked branch.

#### Example

```bash
gswf
```

#### Exit codes

* **0**: The branch was selected and switched, or selection was canceled.
* **1**: git fetch, fzf, or git switch failed.

