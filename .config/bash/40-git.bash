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

gswm() {
  local main_branch
  main_branch="$(git_main_branch)" || {
    echo "Could not determine main branch" >&2
    return 1
  }

  git switch "$main_branch"
}

gswd() {
  local dev_branch
  dev_branch="$(git_develop_branch)" || {
    echo "Could not determine develop branch" >&2
    return 1
  }

  git switch "$dev_branch"
}

gbs() {
  if ! command -v fzf >/dev/null 2>&1; then
    echo "fzf is required for gbs" >&2
    return 1
  fi

  local branch
  branch="$(git branch --format='%(refname:short)' | fzf)"
  [ -n "$branch" ] && git switch "$branch"
}

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

grt() {
  local root
  root="$(git rev-parse --show-toplevel)" || return 1
  cd "$root" || return 1
}

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
