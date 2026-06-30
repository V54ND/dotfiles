# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Zsh theme
ZSH_THEME="agnoster"

# Plugins
plugins=(git)

# Source oh-my-zsh
source "$ZSH/oh-my-zsh.sh"

unalias gup 2>/dev/null || true
unfunction git_develop_branch gup 2>/dev/null || true

git_develop_branch() {
  git rev-parse --git-dir >/dev/null 2>&1 || return 1

  local ref
  for ref in develop dev devel development; do
    if git show-ref -q --verify "refs/heads/$ref"; then
      printf '%s\n' "$ref"
      return 0
    fi
    if git show-ref -q --verify "refs/remotes/origin/$ref"; then
      printf '%s\n' "$ref"
      return 0
    fi
  done

  return 1
}

gup() {
  if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "Not a git repository" >&2
    return 1
  fi

  git fetch --all --prune || return 1
  git pull --ff-only || return 1

  local current_branch dev_branch
  dev_branch="$(git_develop_branch)" || return 0
  current_branch="$(git_current_branch)" || return 0

  if [ "$current_branch" != "$dev_branch" ] &&
    git ls-remote --exit-code --heads origin "$dev_branch" >/dev/null 2>&1; then
    git fetch origin "$dev_branch:refs/heads/$dev_branch"
  fi
}

# User configuration
# export MANPATH="/usr/local/man:$MANPATH"

# You can set PATH here, just uncomment the line below and modify as needed
# export PATH="/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

#
#
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools

eval "$(zoxide init zsh)"°
