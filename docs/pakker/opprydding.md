# Opprydding i installerte pakker

## Datagrunnlag

- Homebrew: 265 formulaer, hvorav 56 toppnivåpakker, samt 53 casks.
- Nix: én dotfiles-profil med 32 pakker.
- Atuin: 17 189 historikkoppføringer analysert.
- Atuin-statistikken mangler tidsstempler. Treffene viser derfor samlet historisk
  bruk, ikke om verktøyene har vært brukt nylig.
- GUI-apper kan startes via en app-launcher og kan derfor ikke vurderes
  pålitelig fra shellhistorikken.
- Den midlertidige historikkdumpen ble slettet etter analysen.

## Nix

Følgende pakker håndteres av dotfiles-profilen:

- Shell og terminal: `atuin`, `direnv`, `starship`, `tmux`, `neovim`,
  `carapace`.
- Programmeringsspråk og runtime: `kotlin`, `ktlint`, `python313`, `uv`.
- Git og versjonskontroll: `git`, `gh`, `lazygit`, `delta`, `bfg`.
- Filverktøy og søk: `ack`, `bat`, `chafa`, `eza`, `exiftool`, `fd`, `timg`,
  `tree`, `cloc`, `dust`, `peco`.
- Nedlasting og nettverk: `curl`, `wget`, `yt-dlp`.
- JSON, YAML og databehandling: `jq`, `yq`, `yamllint`, `jsonnet`.
- Database: `flyway`.
- Dokumentasjon og tekst: `asciinema`.
- Mobilutvikling: `cocoapods`, `maestro`.
- Diverse: `btop`, `glow`, `macchina`, `pastel`, `tealdeer`.

## Homebrew-toppnivåpakker

`ansible`, `asciinema`, `aspell`, `awscli`, `azure-cli`, `bash`,
`brew-cask-completion`, `cbonsai`, `chafa`, `cmatrix`, `cocoapods`,
`diff-so-fancy`, `envchain`, `exiftool`, `fd`, `flyway`, `fzf`, `ghc`, `go`,
`gqlplus`, `gradle`, `helm`, `jenv`, `jq`, `kotlin`, `ktlint`, `kube-ps1`,
`kubeconform`, `kubectx`, `lima`, `mas`, `maven`, `node`,
`pandoc`, `pass`, `pinentry-mac`, `postgis`, `pyenv-virtualenv`, `qemu`,
`qpdf`, `ripgrep`, `socat`, `superfile`, `terminal-notifier`, `testssl`,
`tfenv`, `thefuck`, `timg`, `tuxedo`, `viu`, `watch`, `youtube-dl`, `zoxide`,
`zsh-autosuggestions`, `zsh-syntax-highlighting`.

I tillegg finnes eksplisitt installerte pakker som nå også er avhengigheter,
blant annet `coreutils`, `ffmpeg`, `gnupg`, `kubernetes-cli`, `libpq`,
`opencode`, `poppler`, `pyenv`, `readline`, `ruby` og `tree`.

## Homebrew-casks

`1password`, `1password-cli`, `adobe-acrobat-reader`, `affinity-photo`,
`alfred`, `android-studio`, `arc`, `claude-code@latest`, `discord`, `docker`,
`docker-desktop`, `figma`, `firefox`, `ghostty`, `google-chrome`,
`grandperspective`, `helium-browser`, `idrive`, `inkscape`, `intellij-idea`,
`iterm2`, `jetbrains-toolbox`, `jordanbaird-ice`, `keystore-explorer`, `kitty`,
`microsoft-auto-update`, `microsoft-teams`, `miro`, `notion`, `notunes`,
`obsidian`, `postman`, `rectangle`, `remarkable`, `sbx`, `signal`, `soapui`,
`spotify`, `steam`, `sublime-text`, `temurin@8`, `temurin@11`, `temurin@17`,
`temurin@21`, `temurin@25`, `tuna`, `visual-studio-code`, `vlc`, `zen`, samt
fire font-casks.

## Klare ryddekandidater

Ingen eller tilnærmet ingen treff i hele Atuin-historikken:

- Ingen gjenværende klare Homebrew-kandidater i denne gruppen.
- Nix: `ack`, `bfg`, `peco`, `yq`, `yamllint`, `yt-dlp`.
- `pyenv` og `pyenv-virtualenv`: `pyenv versions` viser bare `system`; ingen
  Python-versjoner eller virtuelle miljøer forvaltes av pyenv. Kan fjernes og
  er allerede erstattet av Nix Python og `uv`.
- `youtube-dl`: besluttet fjernet; erstattet av Nix-pakken `yt-dlp`.
- `ripgrep`: flyttet til Nix. Homebrew-kopien kan fjernes etter at Nix-profilen
  er aktivert.

## Overlapp mellom Homebrew og Nix

Det faktiske overlappet er `fd`, `jq` og `tree`. Ingen av dem står lenger i
`Brewfile`.

| Pakke | Homebrew-avhengige pakker | Vurdering |
| --- | --- | --- |
| `fd` | Ingen | Brew-kopien kan avinstalleres. |
| `jq` | Ingen | Brew-kopien kan avinstalleres. |
| `tree` | `ansible`, `pass` | Må beholdes som transitiv Brew-avhengighet. |

Kjør utenfor sandkassen:

```sh
brew uninstall fd jq
```

Etter at den oppdaterte Nix-profilen er aktivert, kan `brew autoremove` også
fjerne den gamle Homebrew-installasjonen av `ripgrep`.

## Besluttede endringer

- `ghc`: fjernes; Haskell er ikke lenger i aktiv bruk.
- `kotlin` og `ktlint`: flyttes fra Homebrew til Nix.
- `exiftool`: beholdes, men flyttes fra Homebrew til Nix. ExifTool er fortsatt
  det mest komplette generelle CLI-verktøyet for metadata og brukes valgfritt
  av Superfile-konfigurasjonen. `exiv2` er et raskere og smalere alternativ for
  hovedsakelig EXIF, IPTC og XMP i bilder, men er ikke en full erstatning.
- Kubernetes-verktøyene beholdes foreløpig og vurderes samlet for en senere
  migrering til Nix.
- `testssl`: fjernes; TLS- og SSL-analyse er ikke i aktiv bruk.
- `lima`, `qemu` og `postgis`: fjernes; ikke i aktiv bruk.
- `flyway`: beholdes for Java-prosjekter og flyttes fra Homebrew til Nix.
- `cocoapods` og `maestro`: beholdes for mobilprosjektet og flyttes fra
  Homebrew til Nix. Android Studio og Temurin 17 beholdes som casks.
- `chafa`: beholdes som bilde-backend for `fzf-preview.sh` og flyttes til Nix.
- `timg`: beholdes for manuell visning av bilder og video i terminalen og
  flyttes til Nix. Pakken har en stor multimedia-closure.
- `viu`: fjernet; rollen dekkes av `chafa` og `timg`.
- `qpdf`: fjernes; PDF-transformasjon er ikke i aktiv bruk.
- `asciinema`: beholdes og flyttes fra Homebrew til Nix.
- `aspell` og `pandoc`: fjernes.

## Sjeldent brukt

| Pakke eller kommando | Treff |
| --- | ---: |
| `cocoapods` (`pod`) | 1 |
| `qpdf` | 1 |
| `tmux` | 1 |
| `kubeconform` | 2 |
| `awscli` (`aws`) | 3 |
| `go` | omtrent 6 |
| `watch` | 6 |
| `tfenv` | 7 |
| `neovim` (`nvim`) | 8 |
| `gradle` | 4 direkte; `./gradlew` 105 ganger |
| `timg` | 4 |
| `viu` | 3 |
| `pandoc` | 4 |

## Ikke vurdert som ubrukt

Shell-integrasjoner brukes indirekte selv med få eksplisitte treff:
`atuin`, `direnv`, `starship`, `carapace`, `fzf`, `fd`, `eza`, `zoxide`,
`thefuck`, `zsh-autosuggestions` og `zsh-syntax-highlighting`.

GUI-appene kan ikke vurderes pålitelig fra shellhistorikk. Det finnes likevel
tydelig funksjonell overlapp mellom:

- Fem nettlesere: Arc, Firefox, Chrome, Helium og Zen.
- Tre terminaler: Ghostty, Kitty og iTerm2.
- To launchere: Alfred og Tuna.
- Postman og SoapUI.
- Docker og Docker Desktop.
- Fem Temurin-versjoner.
