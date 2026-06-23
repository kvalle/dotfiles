# Agents

This file is the source of truth for AI agents working in this repository.

## Golden rule

**Always edit files in `~/dotfiles/`.** Files under `~/.config/`, `~/`, etc.
are symlinks pointing here. Never edit the symlink targets directly.

## Sandbox-begrensning

AI-agenter i dette repoet kjøres i en sandbox som kun har skrivetilgang
til `~/dotfiles/`. Alt som krever endringer utenfor — som å kjøre
`scripts/setup/symlinks.sh`, opprette/slette kataloger under `~/.config/`,
eller kjøre `brew` — må brukeren utføre selv. Agenten kan oppgi kommandoene,
men ikke kjøre dem.

## Symlink mapping

The source of truth for symlinks is `symlinks.conf`.

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
| `kitty/` | `~/.config/kitty` |
| `atuin/` | `~/.config/atuin` |
| `cplt/config.toml` | `~/.config/cplt/config.toml` |
| `ai/opencode/opencode.jsonc` | `~/.config/opencode/opencode.jsonc` |
| `ai/opencode/tui.jsonc` | `~/.config/opencode/tui.jsonc` |
| `tealdeer/` | `~/.config/tealdeer` |
| `tuxedo/` | `~/.config/tuxedo` |
| `superfile/config.toml` | `~/Library/Application Support/superfile/config.toml` |
| `superfile/hotkeys.toml` | `~/Library/Application Support/superfile/hotkeys.toml` |
| `ai/skills/` | `~/.agents/skills` |
| `ai/skills/` | `~/.claude/skills` |
| `ai/.skill-lock.json` | `~/.agents/.skill-lock.json` |
| `ai/claude/settings.json` | `~/.claude/settings.json` |
| `zen/user.js` | `<Zen profile dir>/user.js` |

## Adding new tool configuration

1. Create the config file/directory in this repo
2. Add the symlink to `symlinks.conf`
3. If the tool is installed via Homebrew, add it to `Brewfile`

## Key scripts

- `scripts/setup.sh` — Full bootstrap for a new machine (Homebrew, symlinks,
  macOS defaults, secrets)
- `scripts/update.sh` — Ongoing maintenance: updates Homebrew, git submodules,
  tldr pages, jenv, and agent skills
- `symlinks.conf` — Declarative symlink table (source of truth)
- `Brewfile` — Declarative package list; add new packages here and run
  `brew bundle`

## Repository structure

| Directory/file | Purpose |
| --- | --- |
| `bin/` | Custom scripts added to PATH |
| `zsh/` | Modular zsh config (sourced by zshrc in order) |
| `scripts/` | Bootstrap, update, and maintenance scripts |
| `ai/` | AI agent skills and config (updated via `npx skills update -g -y`) |
| `<tool>/` | Configuration for that specific tool |
