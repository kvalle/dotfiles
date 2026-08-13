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
entrypoints.

Machine-changing operations such as Homebrew updates, Nix profile changes,
symlink setup, macOS defaults, and secrets setup must be tested manually outside
the sandbox.

## Script domains

Keep domain logic in `scripts/<domain>/` and shared shell helpers in
`scripts/lib/`. A domain — `brew`, `nix`, `symlinks`, `secrets`, and so on —
owns one area of the setup. There is no registration step: the entrypoints know
nothing about a domain beyond the file names below, so the file name *is* the
contract.

- **`setup.sh`** — brings the domain from nothing to configured. Run by
  `scripts/setup.sh`. Idempotent: running it on an already configured machine
  is a no-op, not a second install. It fails fast (`set -euo pipefail`), since
  a half-finished install is worse than none, and a non-zero exit stops the
  bootstrap.
- **`update.sh`** — refreshes what is already installed. Run by
  `scripts/update.sh`. Optional; most domains have nothing to update. A partial
  failure must not abort the rest of the update, so it reports what went wrong
  and continues where it can (`set -uo pipefail`, deliberately without `-e`). A
  missing optional tool is a `dotfiles_warn` and `exit 0`; a real failure exits
  non-zero, for the caller to record and report.
- **`verify.sh`** — answers whether the domain is correctly set up. Run by
  `scripts/verify.sh`, either as part of a full run or on its own
  (`scripts/verify.sh symlinks`). It only reads: it changes nothing and is safe
  to run at any time. It sources `lib/common.sh` and `lib/verify-output.sh`,
  writes its own `verify_header`, reports every finding with `verify_pass`,
  `verify_fail` or `verify_warn`, and ends with `verify_finish`, which returns 0
  when nothing failed and 1 otherwise. It collects all findings rather than
  stopping at the first, so it sets `set -o pipefail` and never `-e`. Running it
  directly must look exactly like running it through `scripts/verify.sh`.
- **`common.sh`** — helpers shared between that domain's own scripts. Sourced,
  never executed.
- **Anything else** — a tool belonging to the domain, named after what it does:
  `nix/apply.sh`, `skills/manifest.sh`, `themes/generate-starship.rb`. It may
  take flags and be run by hand; the scripts above call it.

Every script resolves its own directory and works from any working directory.
Apart from documented flags such as `symlinks/setup.sh --prune`, the entrypoints
call them without arguments.

Files in `scripts/lib/` are sourced, never run. They define functions and
variables, have no side effects at load time, and set no error policy of their
own — they inherit the caller's, as `lib/common.sh` states at the top. A file
there is never a domain, whatever it is named.

`scripts/verify.sh` discovers its domains from `scripts/*/verify.sh` and runs
them alphabetically, so a new domain needs no entry anywhere. `scripts/setup.sh`
still lists them explicitly: bootstrap order encodes real dependencies, while
verification order is arbitrary.

Every script is bash and states one of the three policies above; `lib/` states
none. Keep it that way when adding a script.

Every setup script sources `lib/common.sh` and reports through it: a step opens
with `dotfiles_info` and closes with `dotfiles_success`, a skipped or partial
step is a `dotfiles_warn`, and a fatal one is `dotfiles_die`. Raw `echo` is for
data the user is meant to read or copy, not for status.

## Repository structure

See the structure table in `README.md`.
