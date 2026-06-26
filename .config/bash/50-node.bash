# shellcheck shell=bash

alias ni='npm install'
alias nr='npm run'
alias nt='npm test'
alias nb='npm run build'
alias nd='npm run dev'

if command -v npx >/dev/null 2>&1; then
  alias ncu='npx npm-check-updates -i'
fi
