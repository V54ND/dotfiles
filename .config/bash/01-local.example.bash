# shellcheck shell=bash

# Copy this file to 01-local.bash for machine-specific or private settings.
# 01-local.bash is ignored by git and loads before optional shell features.

# Private tokens and credentials belong in 01-local.bash, not committed files.
# export OPENAI_API_KEY="replace-me"

# Local paths and work-only settings are also good candidates for 01-local.bash.
# export AWS_SHARED_CREDENTIALS_FILE="$HOME/.aws/credentials"
# export PATH="$HOME/bin:$PATH"

# Disable ble.sh on a slow terminal or RDP machine without changing tracked files.
# export DOTFILES_ENABLE_BLESH=0
