# Agents

This file is the source of truth for AI agents working in this repository.

## Golden rule

**Always edit files in `~/dotfiles/`.** Files under `~/.config/`, `~/`, etc.
are symlinks pointing here. Never edit the symlink targets directly.

## Symlink mapping

| Source (this repo) | Symlink destination |
| --- | --- |
| `zshrc` | `~/.zshrc` |
| `zprofile` | `~/.zprofile` |
| `git/` | `~/.config/git` |
| `python/pythonrc.py` | `~/.config/python/pythonrc.py` |
| `ghci/ghci.conf` | `~/.config/ghci/ghci.conf` |
| `starship.toml` | `~/.config/starship.toml` |
| `lazygit/` | `~/.config/lazygit` |
| `ghostty/` | `~/.config/ghostty` |
| `atuin/` | `~/.config/atuin` |
| `cplt/config.toml` | `~/.config/cplt/config.toml` |
| `opencode/opencode.jsonc` | `~/.config/opencode/opencode.jsonc` |
| `opencode/tui.jsonc` | `~/.config/opencode/tui.jsonc` |
| `tealdeer/` | `~/.config/tealdeer` |
| `tuxedo/` | `~/.config/tuxedo` |
| `superfile/config.toml` | `~/Library/Application Support/superfile/config.toml` |
| `superfile/hotkeys.toml` | `~/Library/Application Support/superfile/hotkeys.toml` |
| `agents/skills/` | `~/.agents/skills` |
| `agents/.skill-lock.json` | `~/.agents/.skill-lock.json` |
| `zen/user.js` | `<Zen profile dir>/user.js` |

## Adding new tool configuration

1. Create the config file/directory in this repo
2. Add the symlink to `setup/symlinks.sh`
3. If the tool is installed via Homebrew, add it to `Brewfile`

## Key scripts

- `setup.sh` — Full bootstrap for a new machine (Homebrew, symlinks, macOS
  defaults, secrets)
- `update.sh` — Ongoing maintenance: updates Homebrew, git submodules, tldr
  pages, jenv, and agent skills
- `Brewfile` — Declarative package list; add new packages here and run
  `brew bundle`

## Repository structure

| Directory/file | Purpose |
| --- | --- |
| `bin/` | Custom scripts added to PATH |
| `functions/` | Shell functions sourced by zshrc |
| `setup/` | Bootstrap and setup scripts |
| `agents/` | AI agent skills (updated via `npx skills update -g -y`) |
| `<tool>/` | Configuration for that specific tool |
