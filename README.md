# dotfiles

Configuration and setup scripts for macOS. Managed as symlinks from this
repository into `~/.config/` and other locations.

## Setting up a new machine

Clone the repository somewhere, for example to `~/dotfiles/`:

```sh
git clone https://github.com/kvalle/dotfiles.git ~/dotfiles
~/dotfiles/scripts/setup.sh
```

This installs Determinate Nix and the packages from `nix/`, installs the
remaining packages and apps from `Brewfile`, sets up development tools,
configures macOS defaults and creates the symlinks.

Secrets are declared in `secrets.conf` and fetched from the 1Password CLI (`op`)
by `scripts/secrets/setup.sh`, which runs last. The script starts an interactive
login when needed and stores each file in `~/.secrets/` with mode `600`.

The symlink setup keeps correct links and repairs broken ones automatically.
Wrong symlinks and regular files or directories are overwritten only after
interactive confirmation.

## Updating

```sh
~/dotfiles/scripts/update.sh
```

Updates Homebrew and Nix packages, git submodules, tldr pages, jenv shims and
agent skills. When run interactively, the skills tool asks before deleting local
copies of skills that have been removed upstream.

## Documentation

See the [documentation index](docs/README.md).

## Structure

| Directory/file  | Contents                                                  |
| --------------- | --------------------------------------------------------- |
| `bin/`          | Custom scripts (added to PATH)                            |
| `zsh/`          | Modular zsh config (sourced by zshrc in order)            |
| `scripts/`      | Bootstrap, update and maintenance                         |
| `docs/`         | Checklists and reference material                         |
| `ai/`           | Configuration and manifest for AI agents                  |
| `Brewfile`      | Declarative package list for Homebrew                     |
| `nix/`          | Declarative package list and lockfile for Nix             |
| `fzf-git.sh/`   | Third-party submodule; updated from upstream, do not edit |
| `symlinks.conf` | Declarative symlink table (source of truth)               |
| `secrets.conf`  | Declarative secrets table, fetched from 1Password         |
| `<tool>/`       | Configuration for that specific tool                      |
