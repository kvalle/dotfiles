# dotfiles

Konfigurasjon og oppsettscripts for macOS. Administrert som symlinker fra
dette repoet til `~/.config/` og andre steder.

## Oppsett på ny maskin

Repoet må klones til `~/dotfiles/`.

```sh
git clone https://github.com/kjetil/dotfiles.git ~/dotfiles
~/dotfiles/scripts/setup.sh
```

Dette installerer Homebrew og pakker fra `Brewfile`, setter opp nvm og
fzf, konfigurerer macOS-defaults, og oppretter symlinker.

Secrets hentes fra 1Password CLI (`op`) via `scripts/setup/secrets.sh`,
som kjøres til slutt. Dette krever at du er logget inn i `op` på forhånd.

## Oppdatering

```sh
~/dotfiles/scripts/update.sh
```

Oppdaterer Homebrew-pakker, git submoduler, tldr-sider, jenv-shims og
agent skills.

## Struktur

| Katalog/fil  | Innhold                                  |
| ------------ | ---------------------------------------- |
| `bin/`       | Custom scripts (legges til i PATH)       |
| `functions/` | Shell-funksjoner sourcet av zshrc        |
| `scripts/`   | Bootstrap, oppdatering og vedlikehold    |
| `Brewfile`   | Deklarativ pakkeliste for Homebrew       |
| `agents/`    | AI agent skills                          |
| `<tool>/`    | Konfigurasjon for det aktuelle verktøyet |
