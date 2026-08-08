# Bruk av Nix

Nix er primær pakkekilde for CLI-verktøy på Apple Silicon. Pakker migreres
gradvis fra Homebrew; Homebrew beholdes for pakker og macOS-apper som ikke er
hensiktsmessige å håndtere med Nix.

```sh
~/dotfiles/scripts/nix/apply.sh
```

Scriptet aktiverer pakkene fra den låste `nixpkgs`-revisjonen i
`nix/flake.lock`. Dotfiles-profilen ligger foran Homebrew i `PATH`.

Se pakker i standard- og dotfiles-profilen, samt overlappende kommandoer:

```sh
~/dotfiles/scripts/nix/audit-profiles.sh
```
