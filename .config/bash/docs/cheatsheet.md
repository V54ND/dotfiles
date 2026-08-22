# Bash Cheatsheet

Quick reference for the interactive Git Bash setup.

## Prompt and errors

| Command | Purpose |
| --- | --- |
| `errors` | Show the last 30 failed commands |
| `errors 100` | Show the last 100 failed commands |
| `cheat` | Open this file in `glow` |
| `cheatsheet` | Same as `cheat` |
| `dotfiles-doctor` | Check required tools, optional tools, and configuration |

Failed commands are recorded in `$XDG_STATE_HOME/bash/errors.log`. The prompt
shows the exit code of the last failed command; the red `✗N` Starship segment is
the number of recorded failures.

## Navigation and files

| Command | Purpose |
| --- | --- |
| `l` | List files |
| `ll` | Long listing with Git information |
| `la` | List including hidden files |
| `lla` | Long listing including hidden files |
| `z <words>` | Jump to a frequently used directory with zoxide |
| `mkcd <dir>` | Create a directory and enter it |
| `lg` | Open lazygit |

The listing aliases use `eza` when installed and fall back to `ls`.

## Git aliases

| Alias | Expands to |
| --- | --- |
| `gs` / `gst` | `git status` |
| `ga` | `git add` |
| `gaa` | `git add --all` |
| `gc` | `git commit -v` |
| `gcm "message"` | `git commit -m "message"` |
| `gp` | `git push` |
| `gpf` | `git push --force-with-lease` |
| `gl` | `git pull` |
| `gf` | `git fetch` |
| `gfa` | `git fetch --all --prune` |
| `gd` | `git diff` |
| `gds` | `git diff --staged` |
| `gb` | `git branch` |
| `gbd` | `git branch -d` |
| `gco <branch>` | `git checkout <branch>` |
| `gcb <branch>` | `git checkout -b <branch>` |
| `gsw <branch>` | `git switch <branch>` |
| `gswc <branch>` | `git switch -c <branch>` |
| `gswm` | Switch to the detected main branch |
| `gswd` | Switch to the detected develop branch |
| `gswf` | Fetch and interactively switch branches |
| `gbs` | Select and switch to a branch with fzf |
| `gcbcopy` | Copy the current branch name |
| `grt` | Change to the repository root |
| `gup` | Fetch and fast-forward pull the current branch |

## Node.js

| Alias | Expands to |
| --- | --- |
| `ni` | `npm install` |
| `nr` | `npm run` |
| `nt` | `npm test` |
| `nb` | `npm run build` |
| `nd` | `npm run dev` |
| `vt` | `npx vitest` |

## Utilities

| Command | Purpose |
| --- | --- |
| `compress [options] <files>` | Encode videos to H.264 MP4 |
| `logpipe` | Format input from a pipe |
| `logpipe -n` | Format piped input with line numbers |
| `logpipe -t` | Format and pass input to the next command |
| `extract-failed <log>` | Extract unique `.ts`/`.tsx` paths from `FAIL` lines |
| `pbcopy` | Copy stdin to the Windows clipboard |
| `pbpaste` | Print the Windows clipboard |

Examples:

```bash
rg --files -g '*.mp4' -g '*.mov' | logpipe -n
compress --quality 26 --preset medium recording.mov
extract-failed test-output.log
```

## Documentation

| Command | Purpose |
| --- | --- |
| `bash_docs` | Generate Markdown from shdoc annotations |
| `bash_docs_view` | View all generated function docs |
| `cheat` | View this cheatsheet |
| `dotfiles-doctor` | Check the dotfiles installation |

Generated function docs live in `~/.config/bash/docs/generated/`.

## Startup order

Interactive files in `~/.config/bash/` load lexically:

```text
00-env → 02-error-status → 10-history → 20-tools → 30-aliases
→ 40-git → 50-node → 60-functions → 70-docs → 98-starship → 99-zoxide
```

Starship is initialized before zoxide because zoxide requires its hook to be
present directly in `PROMPT_COMMAND`.
