# ------------------------------------------------------------------------------
# Pakker kan annoteres med tagger i kommentarfeltet:
#
#   [verify]            Sjekkes av verify.sh (at kommando finnes i PATH)
#   [verify cmd:<cmd>]  Som [verify], men sjekker <cmd> istedenfor pakkenavn
#   [verify zsh-plugin] Sjekkes som lastet zsh-plugin
#   [self-updates]      Appen oppdaterer seg selv; ekskluderes fra upgrade.sh
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Taps
# ------------------------------------------------------------------------------

tap "1password/tap"
tap "anomalyco/tap"
tap "azure/kubelogin"
tap "jakehilborn/jakehilborn"
tap "navikt/tap"
tap "sdkman/tap"
tap "gromgit/brewtils"
tap "webstonehq/tap"

# ------------------------------------------------------------------------------
# Shell og terminal
# ------------------------------------------------------------------------------

brew "bash"                        # Nyere bash enn macOS sin innebygde
brew "atuin"                       # [verify] Shell-historikk med søk og synkronisering
brew "direnv"                      # [verify] Per-katalog miljøvariabler
brew "fzf"                         # [verify] Fuzzy finder for terminal
brew "starship"                    # [verify] Kryssplattform shell-prompt
brew "tmux"                        # [verify] Terminal multiplexer
brew "thefuck"                     # [verify] Korrigerer forrige kommando
brew "zsh-autosuggestions"         # [verify zsh-plugin] Autoforslag i zsh
brew "zsh-syntax-highlighting"     # [verify zsh-plugin] Syntaksutheving i zsh
brew "webstonehq/tap/tuxedo"       # Tastaturdriven terminal-UI for todo.txt
cask "ghostty"                     # [self-updates] GPU-akselerert terminalemulator
cask "kitty"                       # Alternativ terminal m/ innebygd bilde-paste-støtte

# ------------------------------------------------------------------------------
# Git og versjonskontroll
# ------------------------------------------------------------------------------

brew "git"                         # [verify] Versjonskontroll
brew "gh"                          # [verify] GitHub CLI
brew "lazygit"                     # [verify] Terminal-UI for git
brew "git-delta"                   # [verify cmd:delta] Penere git-diff (syntax-highlighting pager)
brew "bfg"                         # Fjerne sensitiv data fra git-historikk

# ------------------------------------------------------------------------------
# Filverktøy og søk
# ------------------------------------------------------------------------------

brew "ack"                         # Søk i kildekode (raskere enn grep)
brew "bat"                         # [verify] cat med syntaksutheving
brew "eza"                         # [verify] Moderne erstatning for ls
brew "fd"                          # [verify] Raskere alternativ til find
brew "tree"                        # Vis mappestruktur som tre
brew "superfile"                   # Terminal-filbehandler
brew "peco"                        # Interaktiv filtrering
brew "cloc"                        # Tell kodelinjer per språk
brew "dust"                        # Visuell diskbruk (moderne du)

# ------------------------------------------------------------------------------
# Nedlasting og nettverksverktøy
# ------------------------------------------------------------------------------

brew "curl"                        # HTTP-klient
brew "wget"                        # Nedlasting fra nett
brew "yt-dlp"                      # Last ned video fra YouTube m.fl.

# ------------------------------------------------------------------------------
# JSON, YAML og databehandling
# ------------------------------------------------------------------------------

brew "jq"                          # JSON-prosessering i terminal
brew "yq"                          # YAML-prosessering (som jq for YAML)
brew "yamllint"                    # YAML-linter
brew "jsonnet"                     # Templating-språk for JSON/YAML

# ------------------------------------------------------------------------------
# Programmeringsspråk og runtime
# ------------------------------------------------------------------------------

brew "node"                        # JavaScript runtime
brew "go"                          # Go-programmeringsspråk
brew "ruby"                        # Ruby-programmeringsspråk
brew "ghc"                         # Glasgow Haskell Compiler
brew "kotlin"                      # Kotlin-programmeringsspråk
brew "readline"                    # Bibliotek for linjeredigering (avhengighet)

# ------------------------------------------------------------------------------
# Versjonshåndtering for språk/verktøy
# ------------------------------------------------------------------------------

brew "pyenv"                       # [verify] Python-versjonshåndtering
brew "pyenv-virtualenv"            # Virtualenv-plugin for pyenv
brew "jenv"                        # [verify] Java-versjonshåndtering
brew "tfenv"                       # Terraform-versjonshåndtering
brew "sdkman-cli"                  # SDK-håndtering (Java, Gradle m.m.)

# ------------------------------------------------------------------------------
# Java/JVM-utvikling
# ------------------------------------------------------------------------------

brew "gradle"                      # Byggesystem for JVM
brew "maven"                       # Byggesystem for Java
brew "ktlint"                      # Kotlin-linter/formatter
cask "temurin@8"                   # Eclipse Temurin JDK 8
cask "temurin@11"                  # Eclipse Temurin JDK 11
cask "temurin@17"                  # Eclipse Temurin JDK 17
cask "temurin@21"                  # Eclipse Temurin JDK 21
cask "temurin@25"                  # Eclipse Temurin JDK 25

# ------------------------------------------------------------------------------
# Cloud, Kubernetes og infrastruktur
# ------------------------------------------------------------------------------

brew "awscli"                      # AWS kommandolinjeverktøy
brew "azure-cli"                   # Azure kommandolinjeverktøy
brew "Azure/kubelogin/kubelogin"   # Azure Kubernetes-innlogging
brew "kubernetes-cli"              # [verify cmd:kubectl] kubectl
brew "kubectx"                     # Bytt mellom k8s-kontekster/namespaces
brew "helm"                        # Kubernetes pakkehåndtering

# ------------------------------------------------------------------------------
# Sikkerhet og passord
# ------------------------------------------------------------------------------

brew "pass"                        # Unix-passordlagring (GPG-basert)
brew "pinentry-mac"                # GPG PIN-dialog for macOS
brew "envchain"                    # Lagre env-variabler i Keychain

# ------------------------------------------------------------------------------
# Mobilutvikling
# ------------------------------------------------------------------------------

brew "cocoapods"                   # iOS avhengighetshåndtering
cask "android-studio"              # Android IDE

# ------------------------------------------------------------------------------
# Diverse CLI-verktøy
# ------------------------------------------------------------------------------

brew "coreutils"                   # GNU core utilities for macOS
brew "exiftool"                    # Les/skriv EXIF-metadata i bilder
brew "btop"                        # Avansert ressursmonitor (CPU, minne, disk, nett)
brew "macchina"                    # Systeminformasjon i terminalen
brew "pastel"                      # Fargeverktøy for terminalen
brew "tealdeer"                    # [verify cmd:tldr] Forenklet man-sider (tldr)
brew "terminal-notifier"           # macOS-varsler fra terminal
brew "watch"                       # Kjør kommando gjentatte ganger
brew "timg"                        # Vis bilder/video i terminalen
brew "displayplacer"               # Styr skjermoppløsning/plassering
brew "brew-cask-completion"        # Zsh-completion for brew cask
brew "gromgit/brewtils/taproom"    # Oversikt over brew taps
brew "anomalyco/tap/opencode"      # [self-updates] AI-drevet kodingsagent for terminalen
brew "navikt/tap/cplt"             # Kernel-level sandbox for AI-agenter

# ------------------------------------------------------------------------------
# Casks – Nettlesere
# ------------------------------------------------------------------------------

cask "arc"                         # [self-updates] Arc-nettleser
cask "firefox"                     # Mozilla Firefox
cask "google-chrome"               # Google Chrome
cask "zen"                         # Zen Browser

# ------------------------------------------------------------------------------
# Casks – Kommunikasjon
# ------------------------------------------------------------------------------

cask "discord"                     # Chat og tale for gaming/community
cask "microsoft-teams"             # Microsoft Teams
cask "signal"                      # Kryptert meldingsapp

# ------------------------------------------------------------------------------
# Casks – Produktivitet og notater
# ------------------------------------------------------------------------------

cask "1password"                   # [self-updates] Passordbehandler
cask "1password-cli"               # 1Password CLI
cask "alfred"                      # Spotlight-erstatning og produktivitet
cask "notion"                      # Notater og wiki
cask "obsidian"                    # Markdown-notater med linking
cask "rectangle"                   # Vindusplassering med tastatur
cask "jordanbaird-ice"             # Skjul ikoner i statusbaren

# ------------------------------------------------------------------------------
# Casks – Utvikling
# ------------------------------------------------------------------------------

cask "docker-desktop"              # Docker Desktop GUI
cask "intellij-idea"               # JetBrains Java/Kotlin IDE
cask "jetbrains-toolbox"           # Håndter JetBrains-verktøy
cask "visual-studio-code"          # Microsoft VS Code
cask "sublime-text"                # Sublime Text editor
cask "postman"                     # API-testing
cask "keystore-explorer"           # GUI for Java keystores
cask "figma"                       # Design og prototyping

# ------------------------------------------------------------------------------
# Casks – Media og underholdning
# ------------------------------------------------------------------------------

cask "spotify"                     # Musikkstreaming
cask "vlc"                         # Medieavspiller (spiller alt)
cask "steam"                       # Spillplattform
cask "notunes"                     # Hindre Apple Music fra å åpne seg

# ------------------------------------------------------------------------------
# Casks – Verktøy og diverse
# ------------------------------------------------------------------------------

cask "grandperspective"            # Visualiser diskbruk
cask "remarkable"                  # reMarkable-tablet synk
cask "font-monaspace"              # GitHub sin monospace-fontfamilie
cask "font-symbols-only-nerd-font" # Nerd Font-symboler (ikoner i terminal)
