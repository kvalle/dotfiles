# dotfiles

Konfigurasjon og oppsettscripts for macOS. Administrert som symlinker fra
dette repoet til `~/.config/` og andre steder.

## Oppsett på ny maskin

Repoet må klones til `~/dotfiles/`.

```sh
git clone https://github.com/kjetil/dotfiles.git ~/dotfiles
~/dotfiles/scripts/setup.sh
```

Dette installerer Determinate Nix og pakker fra `nix/`, installerer gjenværende
pakker og apper fra `Brewfile`, setter opp utviklingsverktøy, konfigurerer
macOS-defaults og oppretter symlinker.

Secrets hentes fra 1Password CLI (`op`) via `scripts/setup/secrets.sh`,
som kjøres til slutt. Dette krever at du er logget inn i `op` på forhånd.

## Oppdatering

```sh
~/dotfiles/scripts/update.sh
```

Oppdaterer Homebrew- og Nix-pakker, git submoduler, tldr-sider, jenv-shims og
agent skills.

## Nix

Nix er primær pakkekilde for CLI-verktøy på Apple Silicon. Pakker migreres
gradvis fra Homebrew; Homebrew beholdes for pakker og macOS-apper som ikke er
hensiktsmessige å håndtere med Nix.

```sh
~/dotfiles/scripts/nix-apply.sh
```

Scriptet aktiverer pakkene fra den låste `nixpkgs`-revisjonen i
`nix/flake.lock`. Dotfiles-profilen ligger foran Homebrew i `PATH`.

Se pakker i standard- og dotfiles-profilen, samt overlappende kommandoer:

```sh
~/dotfiles/scripts/nix-profile-audit.sh
```

## Dokumentasjon

- [Sjekkliste for ny maskin](docs/ny-maskin.md)
- [Catppuccin Macchiato-fargepalett](docs/catppuccin-macchiato-palette.html)

## Struktur

| Katalog/fil  | Innhold                                  |
| ------------ | ---------------------------------------- |
| `bin/`       | Egne scripts (legges til i PATH)          |
| `zsh/`       | Modulær zsh-konfig (sourcet av zshrc)    |
| `scripts/`   | Bootstrap, oppdatering og vedlikehold    |
| `docs/`      | Sjekklister og referansemateriale        |
| `ai/`        | Konfigurasjon og manifest for AI-agenter |
| `Brewfile`   | Deklarativ pakkeliste for Homebrew       |
| `nix/`       | Deklarativ pakkeliste og låsefil for Nix |
| `<tool>/`    | Konfigurasjon for det aktuelle verktøyet |
