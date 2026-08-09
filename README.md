# Dotfiles

Cross-platform dotfiles: Git Bash on Windows, Zsh on macOS, and shared configs for Starship, Neovim, and WezTerm.

## Fresh Windows Setup

Back up any existing dotfiles that you want to keep. Install [Scoop](https://scoop.sh), then Git:

```powershell
scoop install git
```

This repository is designed to live directly in the home directory:

```powershell
git -C $HOME init
git -C $HOME remote add origin git@github.com:V54ND/dotfiles.git
git -C $HOME fetch origin main
git -C $HOME checkout -B main origin/main
```

The checkout stops rather than overwriting conflicting untracked files. After resolving any conflicts, install the configured tools:

```powershell
& "$HOME\bootstrap.ps1"
```

Pass `-WithOptional` to include the extra CLI tools listed below. The script is idempotent, adds the required Scoop buckets, installs the Nerd Fonts, and installs current WezTerm through WinGet. Use `-WhatIf` to preview everything.

Open a new Git Bash, then verify the environment:

```bash
dotfiles-doctor
```

Run the repository checks from PowerShell before committing changes:

```powershell
& "$HOME\check.ps1"
```

## Bash

`.bash_profile` is the tracked login entry point used by WezTerm. It loads `.bashrc`, which in turn loads `~/.config/bash/*.bash` in lexical order.

- `00-env.bash`: XDG defaults
- `01-local.example.bash`: template for early machine-local config
- `10-history.bash`: Git Bash history persistence
- `10-path.bash`: Scoop shims and local bin paths
- `20-tools.bash`: defensive tool initialization
- `30-aliases.bash`: shell aliases
- `40-git.bash`: Git aliases and helpers
- `50-node.bash`: npm aliases
- `60-functions.bash`: custom functions
- `docs.sh`: Bash function documentation generator and viewer
- `99-zoxide.bash`: final zoxide initialization

The shell stays quiet when a tool is missing. Run `dotfiles-doctor` whenever you want a complete dependency and config check.

## Tools

Core shell and editor tools are installed by `bootstrap.ps1`:

- starship, zoxide, fzf, eza, bat
- lazygit, delta, ripgrep, fd, jq, yazi
- neovim, tree-sitter, gcc, make
- ffmpeg, imagemagick, yt-dlp
- shellcheck, glow, winfetch
- JetBrains Mono and Monaspace Nerd Fonts

Optional tools (`bootstrap.ps1 -WithOptional`):

- dust
- procs
- btop and bottom
- hyperfine
- tokei
- doggo
- gping

The bootstrap intentionally uses WinGet for WezTerm because the Scoop manifest is stale.

On macOS, install equivalent packages with Homebrew and use `dotfiles-doctor` to see what is still missing. `.zshrc` loads the shared Starship configuration there.

## Bash Function Docs

`shdoc` is an optional local maintenance dependency and is intentionally not tracked. Install it with:

```bash
mkdir -p ~/.local/bin
curl -fsSL https://raw.githubusercontent.com/reconquest/shdoc/v1.4/shdoc -o ~/.local/bin/shdoc
chmod +x ~/.local/bin/shdoc
```

Generate Markdown docs for documented Bash functions with:

```bash
bash_docs
```

Generated files are written to `~/.config/bash/docs/generated`. View them with:

```bash
bash_docs_view
```

The viewer prefers `glow`, falls back to `bat`, then `less`.

## Local Config

Copy `~/.config/bash/01-local.example.bash` to `~/.config/bash/01-local.bash` for machine-specific paths, work-only settings, API keys, credentials, and early feature flags. The real local file is ignored by git.

## History

Git Bash history is written to `~/.bash_history`. A `PROMPT_COMMAND` hook runs `history -a` and `history -n` after every command to synchronize concurrent sessions. Fzf provides the `Ctrl-R` search interface.

The history hook is installed after prompt tools initialize so Starship can still see the previous command status.

## Config Map

- `~/.config/starship.toml`: cross-platform prompt
- `~/.config/nvim`: LazyVim-based Neovim config
- `~/.config/wezterm`: cross-platform terminal config
- `~/.config/winfetch/config.ps1`: Windows system summary

## Git Symlink on Windows

If an application requires Git at the standard Git for Windows path while Scoop owns the installation:

```powershell
New-Item -ItemType SymbolicLink -Path "C:\Program Files\Git" -Target "$env:USERPROFILE\scoop\apps\git\current"
```
