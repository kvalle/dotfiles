# Migreringsplan fra Homebrew til Nix

Kartleggingen gjelder Apple Silicon og `nixpkgs-unstable`. Nix er primær
pakkekilde for CLI-verktøy, mens Homebrew beholdes der det gir bedre macOS-
integrasjon eller pakken ikke finnes i nixpkgs.

## Migrert

Følgende pakker håndteres nå av `nix/flake.nix`:

- Shell og terminal: `atuin`, `direnv`, `starship`, `tmux`, `neovim`,
  `carapace`.
- Git: `git`, `gh`, `lazygit`, `git-delta`, `bfg`.
- Filverktøy: `ack`, `bat`, `eza`, `fd`, `tree`, `cloc`, `dust`, `peco`.
- Nettverk: `curl`, `wget`, `yt-dlp`.
- Data: `jq`, `yq`, `yamllint`, `jsonnet`.
- Python: `python313`, `uv`.
- Diverse: `btop`, `glow`, `pastel`, `tealdeer`.

## Trivielt å flytte

| Homebrew | Nix-attributt | Verifiseringskommando |
| --- | --- | --- |
| `bash` | `pkgs.bash` | `bash` |
| `tuxedo` | `pkgs.tuxedo` | `tuxedo` |
| `superfile` | `pkgs.superfile` | `superfile` |
| `go` | `pkgs.go` | `go` |
| `gradle` | `pkgs.gradle` | `gradle` |
| `maven` | `pkgs.maven` | `mvn` |
| `ktlint` | `pkgs.ktlint` | `ktlint` |
| `awscli` | `pkgs.awscli2` | `aws` |
| `kubelogin` | `pkgs.kubelogin` | `kubelogin` |
| `kubernetes-cli` | `pkgs.kubectl` | `kubectl` |
| `kubectx` | `pkgs.kubectx` | `kubectx` |
| `helm` | `pkgs.kubernetes-helm` | `helm` |
| `exiftool` | `pkgs.exiftool` | `exiftool` |
| `macchina` | `pkgs.macchina` | `macchina` |
| `watch` | `pkgs.unixtools.watch` | `watch` |
| `cmatrix` | `pkgs.cmatrix` | `cmatrix` |

Foreslått neste chunk: `tuxedo`, `superfile`, `awscli`, `kubelogin`,
`kubernetes-cli`, `kubectx`, `helm`, `exiftool`, `macchina`, `watch` og
`cmatrix`.

## Krever særskilt testing

| Pakke | Årsak |
| --- | --- |
| `fzf` | Setup bruker `brew --prefix` og genererer `~/.fzf.zsh`. |
| `zoxide` | Initialiseringen erstatter shellfunksjonen `cd`. |
| `zsh-autosuggestions` | Shellkonfigurasjonen peker direkte til `/opt/homebrew`. |
| `zsh-syntax-highlighting` | Hardkodet Homebrew-sti og må lastes sent i zsh. |
| `azure-cli` | Nix-utgaven har mer immutable extension-håndtering. |
| `pass` | Må testes sammen med GPG og pinentry. |
| `pinentry-mac` | Darwin-støtten i nixpkgs-metadata er usikker. |
| `envchain` | Må testes mot macOS Keychain. |
| `cocoapods` | Må testes med Xcode, plugins og Ruby-integrasjon. |
| `maestro` | Må testes mot Simulator, ADB og macOS-rettigheter. |
| `terminal-notifier` | Må testes mot notification permissions og appidentitet. |
| `opencode` | Nix-utgaven deaktiverer selvoppdatering. |
| `timg` | Tilgjengelig, men har en stor multimedia-closure. |
| `coreutils` | Kan overskygge macOS-kommandoer og endre scriptoppførsel. |

## Språk og versjonshåndtering

Disse krever en egen designbeslutning fremfor mekanisk flytting:

| Pakke | Årsak |
| --- | --- |
| `node` | NVM og Brew-Node har allerede overlappende ansvar. |
| `ruby` | Repoet har hardkodede `/opt/homebrew/opt/ruby`-stier. |
| `ghc` | Stor closure; prosjektverktøy bør testes. |
| `kotlin` | Må ses sammen med valgt JDK. |
| `tfenv` | Mutable Terraform-versjoner motarbeider Nix-modellen. |
| `jenv` | Ikke godt tilgjengelig; repoet har omfattende integrasjon. |
| `sdkman-cli` | Installerer mutable SDK-er og er en dårlig Nix-match. |
| `readline` | Bibliotek som bør komme transitivt, ikke som brukerpakke. |
| Temurin 8-25 | Registreres ikke automatisk med `java_home` eller jenv. |

Python følger en pragmatisk modell: Nix leverer `python313` for REPL og enkle
skript, samt `uv` som håndterer prosjektspesifikke Python-versjoner, virtuelle
miljøer og avhengigheter. `pyenv` og `pyenv-virtualenv` er derfor fjernet.

## Behold Homebrew

| Pakke | Årsak |
| --- | --- |
| `thefuck` | Ingen aktuell nixpkgs-pakke. |
| `displayplacer` | Ingen aktuell nixpkgs-pakke. |
| `brew-cask-completion` | Homebrew-spesifikk og relevant mens casks beholdes. |
| `taproom` | Homebrew-spesifikt tap-verktøy. |
| `cplt` | Darwin-sandboxing, signering og systemintegrasjon. |

## GUI-apper og fonter

Behold GUI-apper og fonter i Homebrew frem til `nix-darwin` introduseres.
Vanlige Nix-profiler gir ikke tilsvarende integrasjon med `/Applications`,
Launch Services, fontaktivering, selvoppdatering og TCC-rettigheter.

Teknisk tilgjengelige, men ikke anbefalt nå: Kitty, Firefox, VLC,
GrandPerspective, Chrome, Discord, Teams, Signal, 1Password, Obsidian,
Rectangle, Claude Code, IntelliJ, VS Code, Postman og fontene.

Bør forbli i Homebrew: Ghostty, Android Studio, Arc, Helium, Zen, Alfred,
Tuna, Notion, Ice, Docker Desktop, Sublime Text, Figma, Steam, noTunes og
reMarkable.

## Taps

Fjern taps når siste tilhørende pakke er migrert:

- `azure/kubelogin`: etter `kubelogin`.
- `webstonehq/tap`: etter `tuxedo`.
- `anomalyco/tap`: etter eventuell migrering av OpenCode.
- `mobile-dev-inc/tap`: etter eventuell migrering av Maestro.
- `sdkman/tap`: dersom SDKMAN fjernes.
- `gromgit/brewtils`: dersom `taproom` fjernes.

Behold foreløpig `1password/tap` og `navikt/tap`.
