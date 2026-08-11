# Agents

This file is the source of truth for AI agents working in this repository.

## Golden rule

**Always edit files in `~/dotfiles/`.** Files under `~/.config/`, `~/`, etc.
are symlinks pointing here. Never edit the symlink targets directly.

When this repository is the workspace, also read configuration and logs from
`~/dotfiles/`, not through symlink destinations under `~/.config/`, `~/.claude/`,
`~/Library/Application Support`, or similar locations. Use this file and
`symlinks.conf` to locate the source. If required data is not stored in the
repository, ask the user instead of reading it from the home directory.

## Language

Everything written in this repository is English: documentation, comments,
identifiers, and every string the scripts print. There is no split by category —
one language means there is never a question about which side of a line a given
string falls on.

Norwegian remains only where the text is data rather than prose: 1Password entry
titles such as `Digipost GitHub secret`, and quoted upstream strings.

File and directory names are ASCII.

## Sandbox limitation

AI agents in this repository run in a sandbox with write access to `~/dotfiles/`
only. Anything that requires changes outside it — running
`scripts/symlinks/setup.sh`, creating or deleting directories under `~/.config/`,
or running `brew` — must be done by the user. The agent can supply the commands
but not run them.

## Symlink mapping

The source of truth for symlinks is `symlinks.conf`: one line per symlink, with
the source path in this repository and its destination, grouped by purpose. Read
the mapping there — a copy in this file would drift from it.

Zen Browser is the one exception, special-cased in `scripts/symlinks/setup.sh`
because its profile path is dynamic.

## Adding new tool configuration

1. Create the config file/directory in this repo
2. Add the symlink to `symlinks.conf`
3. Add the package where it belongs: `nix/flake.nix` for CLI tools, `Brewfile`
   for casks, macOS-integrated software, and anything not in nixpkgs. See
   `docs/nix/usage.md`

## Removing tool configuration

1. Remove the entry from `symlinks.conf`
2. Delete the config file/directory from this repo
3. Run `scripts/symlinks/setup.sh --prune` to clean up the symlink that is
   otherwise left behind in the home directory

## Key scripts

- `scripts/setup.sh` — Full bootstrap for a new machine. It calls one setup
  script per domain and ends with `scripts/verify.sh`; read it for the
  authoritative list of domains and the order they run in
- `scripts/update.sh` — Ongoing maintenance. Read it for what it updates
- `scripts/verify.sh` — Verify all domains, or one named domain such as
  `scripts/verify.sh symlinks`
- `scripts/symlinks/setup.sh --prune` — Offer to remove symlinks that
  `symlinks.conf` no longer declares. The candidates come from the removed
  lines in the config's git history, so nothing under `$HOME` is scanned;
  `scripts/verify.sh symlinks` warns about the same symlinks without touching
  them
- `symlinks.conf` — Declarative symlink table (source of truth)
- `secrets.conf` — Declarative secrets table: one line per secret with the file
  name under `~/.secrets/` and the `op://` reference to read it from. Both
  `scripts/secrets/setup.sh` and `scripts/verify.sh secrets` iterate over it,
  so adding a secret is a one-line change
- `nix/flake.nix` — Declarative package list for CLI tools, the primary package
  source; applied with `scripts/nix/apply.sh`. The dotfiles profile comes before
  Homebrew on `PATH`. See `docs/nix/usage.md`
- `Brewfile` — Declarative package list for casks, macOS-integrated software,
  and packages not available in nixpkgs; applied with `brew bundle`

`scripts/setup.sh`, `scripts/update.sh`, and `scripts/verify.sh` are stable
entrypoints. Keep domain logic in `scripts/<domain>/` and shared shell helpers
in `scripts/lib/`.

Machine-changing operations such as Homebrew updates, Nix profile changes,
symlink setup, macOS defaults, and secrets setup must be tested manually outside
the sandbox.

## Repository structure

See the structure table in `README.md`.
