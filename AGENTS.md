# Agent instructions

## Source files

Always edit files in this repository, never their symlink destinations under
`~/.config/`, `~/.claude/`, `~/Library/Application Support`, or elsewhere in the
home directory. When this repository is the workspace, also read configuration
and logs from it rather than through those destinations.

`symlinks.conf` is the sole source of truth for symlinks. Zen Browser is the
only exception because its profile path is dynamic. `secrets.conf`, `Brewfile`,
and `nix/flake.nix` are likewise the authoritative manifests for their domains.
Do not duplicate complete manifests in documentation.

## Language

Write repository prose, comments, identifiers, and script output in English.
Non-English text is allowed only when it is data, such as an upstream string or
a 1Password entry title. Keep file and directory names ASCII.

## Sandbox

Agents can write only inside this repository. Do not run operations that change
the host, including Homebrew or Nix changes, macOS defaults, secret setup, or
symlink setup. Provide the command for the user to run instead. Read data from
outside the repository only when the user supplies it.

## Maintenance rules

- Generated files must name their source and regeneration command and have a
  read-only freshness check. Otherwise, treat them as hand-maintained.
- Document external or machine-specific dependencies where they are referenced,
  including whether they are optional. Do not create a second manifest for them.
- Keep tool configuration under the tool's directory. Do not copy runtime state
  back into the repository without an explicit workflow.
- Keep setup idempotent and fail-fast. Updates must continue past independent
  failures. Verification must be read-only and collect all findings.
- A new setup domain needs a corresponding verifier or an explicit reason why it
  cannot be verified.
- Shared shell helpers belong in `scripts/lib/`; domain-specific code belongs in
  `scripts/<domain>/`.
