# Dotfiles

Windows + Git Bash dotfiles with XDG-style config under `~/.config`.

## Bash

`~/.bashrc` is only a loader. Shared Bash config lives in `~/.config/bash/*.bash` and is sourced in lexical order.

- `00-env.bash`: XDG defaults
- `10-path.bash`: Scoop shims and local bin paths
- `10-history.bash`: Git Bash history persistence
- `20-tools.bash`: defensive tool initialization
- `30-aliases.bash`: shell aliases
- `40-git.bash`: Git aliases and helpers
- `50-node.bash`: npm aliases
- `60-functions.bash`: custom functions
- `99-local.example.bash`: template for private local config
- `99-required-tools.bash`: startup warning for missing required tools
- `99-zoxide.bash`: final zoxide initialization

## Tools

Required for the main shell experience:

- starship
- zoxide
- fzf
- eza
- bat
- lazygit
- delta
- ripgrep
- fd
- jq
- yazi

Optional tools:

- atuin
- dust
- procs
- btop
- bottom
- hyperfine
- tokei
- doggo
- gping

Custom helpers may also use `ffmpeg`, `imagemagick`, and `yt-dlp` when installed.

## Scoop

Install the core tools with Scoop:

```bash
scoop install starship zoxide fzf ripgrep fd bat eza lazygit delta jq yazi
```

Optional tools:

```bash
scoop install dust procs btop hyperfine tokei doggo gping
```

Nerd Font setup:

```bash
scoop bucket add nerd-fonts
scoop install JetBrainsMono-NF
```

## Local Config

Copy `~/.config/bash/99-local.example.bash` to `~/.config/bash/99-local.bash` for machine-specific paths, work-only settings, API keys, and credentials. The real `99-local.bash` file is ignored by git.

Set `DOTFILES_CHECK_REQUIRED_TOOLS=0` in local config to silence the required-tool startup check.

## History

Git Bash history is written to `~/.bash_history`. The history module enables append mode and installs a `PROMPT_COMMAND` hook that runs `history -a` and `history -n` after each prompt cycle, so multiple open Git Bash windows append and read history without wiping each other.

The hook is reinstalled after prompt tools initialize, and it is appended after existing prompt hooks so Starship can still see the real exit status of the previous command. zoxide initializes in the final Bash module so Starship does not overwrite its directory-tracking hook.

## Other Configs

- `~/.config/starship.toml`: Starship prompt with Git, Node, Python, Rust, Docker, Kubernetes, command duration, jobs, and status modules.
- `~/.config/nvim`: LazyVim-based Neovim config.
- `~/.config/wezterm`: WezTerm config for Windows.

## Git Symlink In Windows

If you need the Scoop Git install available at the standard Git for Windows path:

```powershell
New-Item -ItemType SymbolicLink -Path "C:\Program Files\Git" -Target "$env:USERPROFILE\scoop\apps\git\current"
```
