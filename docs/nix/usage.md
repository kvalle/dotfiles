# Using Nix

Nix is the primary package source for CLI tools on Apple Silicon. Packages are
migrated from Homebrew gradually; Homebrew is kept for packages and macOS apps
that are not a good fit for Nix.

```sh
~/dotfiles/scripts/nix/apply.sh
```

The script activates the packages from the locked `nixpkgs` revision in
`nix/flake.lock`. The dotfiles profile comes before Homebrew on `PATH`.

List the packages in the default and dotfiles profiles, along with any
overlapping commands:

```sh
~/dotfiles/scripts/nix/audit-profiles.sh
```
