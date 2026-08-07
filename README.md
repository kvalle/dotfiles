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

## Dokumentasjon

Se [dokumentasjonsoversikten](docs/README.md) for oppsett, Nix, terminaltemaer
og verktøyspesifikke instrukser.

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
