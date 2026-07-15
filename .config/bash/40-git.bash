# shellcheck shell=bash

unalias gll gcm gswm gswd gup 2>/dev/null || true
unset -f gll gcm gswm gswd gup 2>/dev/null || true

alias gf='git fetch'
alias gfa='git fetch --all --prune'
alias gc='git commit -v'
alias gcm='git commit -m'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gl='git pull'
alias gs='git status'
alias gst='git status'
alias ga='git add'
alias gaa='git add --all'
alias gca='git commit -v -a'
alias gd='git diff'
alias gds='git diff --staged'
alias gb='git branch'
alias gbd='git branch -d'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gsw='git switch'
alias gswc='git switch -c'

# @description
# Prints the first local default branch found in the current Git repository.
#
# @example
#   git_main_branch
#
# @stdout The detected branch name.
#
# @exitcode 0 A default branch was found.
# @exitcode 1 The current directory is not a Git repository or no default branch exists.
git_main_branch() {
  git rev-parse --git-dir >/dev/null 2>&1 || return 1

  local ref
  for ref in main trunk master; do
    if git show-ref -q --verify "refs/heads/$ref"; then
      printf '%s\n' "$ref"
      return 0
    fi
  done

  return 1
}

# @description
# Prints the first develop-style branch found locally or under origin.
#
# @example
#   git_develop_branch
#
# @stdout The detected branch name.
#
# @exitcode 0 A develop-style branch was found.
# @exitcode 1 The current directory is not a Git repository or no matching branch exists.
git_develop_branch() {
  git rev-parse --git-dir >/dev/null 2>&1 || return 1

  local ref
  for ref in develop dev devel development; do
    if git show-ref -q --verify "refs/heads/$ref"; then
      printf '%s\n' "$ref"
      return 0
    fi
  done

  for ref in develop dev devel development; do
    if git show-ref -q --verify "refs/remotes/origin/$ref"; then
      printf '%s\n' "$ref"
      return 0
    fi
  done

  return 1
}

# @description
# Switches the current Git repository to its detected default branch.
#
# @example
#   gswm
#
# @stderr Prints an error when the default branch cannot be detected.
#
# @exitcode 0 The repository switched to the default branch.
# @exitcode 1 The default branch could not be detected or git switch failed.
gswm() {
  local main_branch
  main_branch="$(git_main_branch)" || {
    echo "Could not determine main branch" >&2
    return 1
  }

  git switch "$main_branch"
}

# @description
# Switches the current Git repository to its detected develop-style branch.
#
# @example
#   gswd
#
# @stderr Prints an error when the develop-style branch cannot be detected.
#
# @exitcode 0 The repository switched to the develop-style branch.
# @exitcode 1 The develop-style branch could not be detected or git switch failed.
gswd() {
  local dev_branch
  dev_branch="$(git_develop_branch)" || {
    echo "Could not determine develop branch" >&2
    return 1
  }

  git switch "$dev_branch"
}

# @description
# Uses fzf to choose a local Git branch and switches to the selected branch.
#
# @example
#   gbs
#
# @stderr Prints an error when fzf is not available.
#
# @exitcode 0 The selected branch was checked out successfully.
# @exitcode 1 fzf is missing, no branch was selected, or git switch failed.
gbs() {
  if ! command -v fzf >/dev/null 2>&1; then
    echo "fzf is required for gbs" >&2
    return 1
  fi

  local branch
  branch="$(git branch --format='%(refname:short)' | fzf)"
  [ -n "$branch" ] && git switch "$branch"
}

# @description
# Copies the current Git branch name to the Windows clipboard.
#
# @example
#   gcbcopy
#
# @stderr Prints an error when clip.exe is unavailable or the current branch cannot be detected.
#
# @exitcode 0 The branch name was copied.
# @exitcode 1 clip.exe is missing, the branch name could not be detected, or clipboard output failed.
gcbcopy() {
  if ! command -v clip.exe >/dev/null 2>&1; then
    echo "clip.exe is required for gcbcopy" >&2
    return 1
  fi

  local branch
  branch="$(git branch --show-current)" || return 1
  [ -n "$branch" ] || {
    echo "Could not determine current branch" >&2
    return 1
  }

  printf '%s' "$branch" | clip.exe
}

# @description
# Changes the current directory to the root of the active Git repository.
#
# @example
#   grt
#
# @exitcode 0 The directory was changed to the Git repository root.
# @exitcode 1 The repository root could not be detected or cd failed.
grt() {
  local root
  root="$(git rev-parse --show-toplevel)" || return 1
  cd "$root" || return 1
}

# @description
# Updates the current Git repository by fetching, pruning, fast-forward pulling, and optionally pulling from the develop-style branch.
#
# @example
#   gup
#
# @stderr Prints an error when the current directory is not a Git repository.
#
# @exitcode 0 The update completed successfully.
# @exitcode 1 The current directory is not a Git repository or a Git update command failed.
gup() {
  if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "Not a git repository" >&2
    return 1
  fi

  local current_branch dev_branch
  current_branch="$(git branch --show-current)" || return 1
  dev_branch="$(git_develop_branch)"

  git fetch --all --prune || return 1

  git pull --ff-only || return 1

  if [ -n "$current_branch" ] &&
    [ "$current_branch" != "$dev_branch" ] &&
    [ -n "$dev_branch" ] &&
    git ls-remote --exit-code --heads origin "$dev_branch" >/dev/null 2>&1; then
    git pull origin "$dev_branch" || return 1
  fi
}

# @description
# Fetches remote branches, lets fzf choose a branch, and switches to the local or tracked branch.
#
# @example
#   gswf
#
# @exitcode 0 The branch was selected and switched, or selection was canceled.
# @exitcode 1 git fetch, fzf, or git switch failed.
gswf() {
  local branch

  git fetch --prune --quiet

  branch="$(
    {
      git for-each-ref --format='%(refname:short)' refs/heads/
      git for-each-ref --format='%(refname:short)' refs/remotes/origin/ |
        sed 's#^origin/##'
    } |
    grep -v '^HEAD$' |
    sort -u |
    fzf \
      --prompt='Switch branch > ' \
      --height=40% \
      --layout=reverse \
      --border
  )"

  [[ -z "$branch" ]] && return

  if git show-ref --verify --quiet "refs/heads/$branch"; then
    git switch "$branch"
  else
    git switch --track "origin/$branch"
  fi
}
