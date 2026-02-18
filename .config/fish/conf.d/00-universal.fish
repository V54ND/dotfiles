
# =========================
# ENV
# =========================
set -x HISTSIZE 10000
set -x AWS_SHARED_CREDENTIALS_FILE ~/.aws/credentials

# =========================
# Aliases (eza)
# =========================
# If eza exists, use it, else fallback to ls
if type -q eza
  alias l   "eza --color=always --color-scale=all --color-scale-mode=gradient --icons=always --group-directories-first"
  alias ll  "eza --color=always --color-scale=all --color-scale-mode=gradient --icons=always --group-directories-first -l --git -h"
  alias la  "eza --color=always --color-scale=all --color-scale-mode=gradient --icons=always --group-directories-first -a"
  alias lla "eza --color=always --color-scale=all --color-scale-mode=gradient --icons=always --group-directories-first -a -l --git -h"
else
  alias l "ls -G"
  alias ll "ls -lah"
  alias la "ls -a"
  alias lla "ls -lah"
end

# =========================
# Git shortcuts
# =========================
alias gf  "git fetch"
alias gll "git fetch; and git pull"
alias gs  "git status"
alias ga  "git add"
alias gaa "git add --all"
alias gd  "git diff"
alias gds "git diff --staged"
alias gl  "git log --oneline -10"
alias gb  "git branch"
alias gbd "git branch -d"
alias gc  "git checkout"
alias gco "git checkout"
alias gcb "git checkout -b"
alias gcm "git commit -m"
alias gca "git commit --amend"
alias gp  "git push -u origin (git branch --show-current)"

# =========================
# NPM
# =========================
alias ncu "npx npm-check-updates -i"

# =========================
# zoxide (optional)
# =========================
if type -q zoxide
  zoxide init fish | source
end

# =========================
# Better default editor
# =========================
if type -q nvim
  set -x EDITOR nvim
else if type -q vim
  set -x EDITOR vim
end

# =========================
# Ensure functions are available (Fish auto-loads from ~/.config/fish/functions)
# =========================


if type -q starship
  starship init fish | source
end
