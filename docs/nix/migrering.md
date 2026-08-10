# Migreringsplan fra Homebrew til Nix

Kartleggingen gjelder Apple Silicon og `nixpkgs-unstable`. Nix er primær
pakkekilde for CLI-verktøy, mens Homebrew beholdes der det gir bedre macOS-
integrasjon eller pakken ikke finnes i nixpkgs.

## Migrert

Følgende pakker håndteres nå av `nix/flake.nix`:

- Shell og terminal: `atuin`, `direnv`, `starship`, `tmux`, `neovim`,
  `carapace`, `tuxedo`.
- Programmeringsspråk: `go`, `kotlin`, `ktlint`.
- Git: `git`, `gh`, `lazygit`, `git-delta`, `bfg`.
- Filverktøy: `ack`, `bat`, `chafa`, `eza`, `exiftool`, `fd`, `ripgrep`,
  `timg`, `tree`, `cloc`, `dust`, `peco`.
- Nettverk: `curl`, `wget`, `yt-dlp`.
- Data: `jq`, `yq`, `yamllint`, `jsonnet`.
- Database: `flyway`, `postgresql_18` (`psql`, `pg_dump`, `pg_restore`).
- Dokumentasjon og tekst: `asciinema`.
- Mobilutvikling: `cocoapods`, `maestro`.
- Python: `python313`, `uv`.
- Diverse: `btop`, `cbonsai`, `cmatrix`, `glow`, `macchina`, `pastel`,
  `tealdeer`, `terminal-notifier`, `watch`.

## Utsatt migrering

| Homebrew | Nix-attributt | Verifiseringskommando |
| --- | --- | --- |
| `bash` | `pkgs.bash` | `bash` |
| `maven` | `pkgs.maven` | `mvn` |
| `kubelogin` | `pkgs.kubelogin` | `kubelogin` |
| `kubernetes-cli` | `pkgs.kubectl` | `kubectl` |
| `kubectx` | `pkgs.kubectx` | `kubectx` |
| `helm` | `pkgs.kubernetes-helm` | `helm` |

Kubernetes-verktøyene beholdes samlet i Homebrew inntil videre. `bash` beholdes
for en moderne Bash-versjon, og Maven beholdes for Java-prosjekter.

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
| `opencode` | Nix-utgaven deaktiverer selvoppdatering. |

## Språk og versjonshåndtering

Disse krever en egen designbeslutning fremfor mekanisk flytting:

| Pakke | Årsak |
| --- | --- |
| `node` | Brew-versjonen kreves av Brew-pakken `opencode`; `fnm` fra Nix styrer versjoner per prosjekt. |
| `ruby` | Repoet har hardkodede `/opt/homebrew/opt/ruby`-stier. |
| `jenv` | Ikke godt tilgjengelig; repoet har omfattende integrasjon. |
| Temurin 8-25 | Registreres ikke automatisk med `java_home` eller jenv. |

Python følger en pragmatisk modell: Nix leverer `python313` for REPL og enkle
skript, samt `uv` som håndterer prosjektspesifikke Python-versjoner, virtuelle
miljøer og avhengigheter. `pyenv` og `pyenv-virtualenv` er derfor fjernet.

## Behold Homebrew

| Pakke | Årsak |
| --- | --- |
| `thefuck` | Ingen aktuell nixpkgs-pakke. |
| `displayplacer` | Ingen aktuell nixpkgs-pakke. |
| `cplt` | Darwin-sandboxing, signering og systemintegrasjon. |
| `awscli` | Beholdes etter eksplisitt bruksvurdering. |
| `azure-cli` | Beholdes etter eksplisitt bruksvurdering. |
| `superfile` | Nixpkgs ligger på 1.3.3, mens Homebrew leverer 1.6.0. |

## GUI-apper og fonter

Behold GUI-apper og fonter i Homebrew frem til `nix-darwin` introduseres.
Vanlige Nix-profiler gir ikke tilsvarende integrasjon med `/Applications`,
Launch Services, fontaktivering, selvoppdatering og TCC-rettigheter.

Teknisk tilgjengelige, men ikke anbefalt nå: Kitty, Firefox, VLC,
GrandPerspective, Chrome, Discord, Teams, Signal, 1Password, Rectangle,
Claude Code, IntelliJ, VS Code, Postman og fontene.

Bør forbli i Homebrew: Ghostty, Android Studio, Arc, Helium, Zen, Tuna, Notion,
Ice, Docker Desktop, Sublime Text, Figma, Steam, noTunes og reMarkable.

## Taps

Fjern taps når siste tilhørende pakke er migrert:

- `azure/kubelogin`: etter `kubelogin`.
- `anomalyco/tap`: etter eventuell migrering av OpenCode.

Behold foreløpig `1password/tap` og `navikt/tap`.
