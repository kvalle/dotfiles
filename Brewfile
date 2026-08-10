# ------------------------------------------------------------------------------
# Pakker kan annoteres med tagger i kommentarfeltet:
#
#   [verify]            Sjekkes av verify.sh (at kommando finnes i PATH)
#   [verify cmd:<cmd>]  Som [verify], men sjekker <cmd> istedenfor pakkenavn
#   [verify zsh-plugin] Sjekkes som lastet zsh-plugin
#   [self-updates]      Appen oppdaterer seg selv; ekskluderes fra scripts/brew/update.sh
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Taps
# ------------------------------------------------------------------------------

tap "1password/tap"
tap "anomalyco/tap"
tap "azure/kubelogin"
tap "jakehilborn/jakehilborn"
tap "navikt/tap"

# ------------------------------------------------------------------------------
# Shell og terminal
# ------------------------------------------------------------------------------

brew "bash"                        # Nyere bash enn macOS sin innebygde
brew "fzf"                         # [verify] Fuzzy finder for terminal
brew "thefuck"                     # [verify] Korrigerer forrige kommando
brew "zoxide"                      # [verify] Smartere cd – husker mest brukte mapper
brew "zsh-autosuggestions"         # [verify zsh-plugin] Autoforslag i zsh
brew "zsh-syntax-highlighting"     # [verify zsh-plugin] Syntaksutheving i zsh
cask "ghostty"                     # [self-updates] Alternativ GPU-akselerert terminalemulator
cask "kitty"                       # Primær terminal m/ innebygd bilde-paste-støtte

# ------------------------------------------------------------------------------
# Git og versjonskontroll
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Filverktøy og søk
# ------------------------------------------------------------------------------

brew "superfile"                   # Terminal-filbehandler


# ------------------------------------------------------------------------------
# Nedlasting og nettverksverktøy
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# JSON, YAML og databehandling
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Programmeringsspråk og runtime
# ------------------------------------------------------------------------------

brew "ruby"                        # Ruby-programmeringsspråk

# ------------------------------------------------------------------------------
# Versjonshåndtering for språk/verktøy
# ------------------------------------------------------------------------------

brew "jenv"                        # [verify] Java-versjonshåndtering

# ------------------------------------------------------------------------------
# Java/JVM-utvikling
# ------------------------------------------------------------------------------

brew "maven"                       # Byggesystem for Java
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

# ------------------------------------------------------------------------------
# Mobilutvikling
# ------------------------------------------------------------------------------

cask "android-studio"              # Android IDE

# ------------------------------------------------------------------------------
# Diverse CLI-verktøy
# ------------------------------------------------------------------------------

brew "displayplacer"               # Styr skjermoppløsning/plassering
brew "anomalyco/tap/opencode"      # [self-updates] AI-drevet kodingsagent for terminalen
brew "navikt/tap/cplt"             # Kernel-level sandbox for AI-agenter

# ------------------------------------------------------------------------------
# Casks – Nettlesere
# ------------------------------------------------------------------------------

cask "arc"                         # [self-updates] Arc-nettleser
cask "firefox"                     # Mozilla Firefox
cask "google-chrome"               # Google Chrome
cask "helium-browser"              # Lettvekts Chromium-nettleser
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
cask "tuna"                        # [self-updates] Moderne app launcher (Quicksilver-inspirert)
cask "notion"                      # Notater og wiki
cask "rectangle"                   # Vindusplassering med tastatur
cask "jordanbaird-ice"             # Skjul ikoner i statusbaren

# ------------------------------------------------------------------------------
# Casks – Utvikling
# ------------------------------------------------------------------------------

cask "docker-desktop"              # Docker Desktop GUI
cask "claude-code@latest"          # Anthropic sin kodingsagent for terminalen
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

cask "vlc"                         # Medieavspiller (spiller alt)
cask "steam"                       # Spillplattform
cask "notunes"                     # Hindre Apple Music fra å åpne seg

# ------------------------------------------------------------------------------
# Casks – Verktøy og diverse
# ------------------------------------------------------------------------------

cask "grandperspective"            # Visualiser diskbruk
cask "remarkable"                  # reMarkable-tablet synk
cask "font-monaspace"              # Monaspace Neon
cask "font-jetbrains-mono-nerd-font" # JetBrains Mono med Nerd Font-ikoner
cask "font-iosevka-nerd-font"        # Iosevka med Nerd Font-ikoner
cask "font-symbols-only-nerd-font" # Nerd Font-ikoner som fallback for fonter uten (f.eks. Monaspace)
