# ------------------------------------------------------------------------------
# Packages can be annotated with tags in the comment field:
#
#   [verify]            Checked by verify.sh (that the command exists on PATH)
#   [verify cmd:<cmd>]  Like [verify], but checks <cmd> instead of the package name
#   [verify zsh-plugin] Checked as a loaded zsh plugin
#   [self-updates]      The app updates itself; excluded from scripts/brew/update.sh
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
# Shell and terminal
# ------------------------------------------------------------------------------

brew "bash"                        # Newer bash than the one macOS ships
brew "fzf"                         # [verify] Fuzzy finder for the terminal
brew "thefuck"                     # [verify] Corrects the previous command
brew "zoxide"                      # [verify] Smarter cd – remembers most-used directories
brew "zsh-autosuggestions"         # [verify zsh-plugin] Autosuggestions in zsh
brew "zsh-syntax-highlighting"     # [verify zsh-plugin] Syntax highlighting in zsh
cask "ghostty"                     # [self-updates] Alternative GPU-accelerated terminal emulator
cask "kitty"                       # Primary terminal with built-in image paste support

# ------------------------------------------------------------------------------
# File tools and search
# ------------------------------------------------------------------------------

brew "superfile"                   # Terminal file manager

# ------------------------------------------------------------------------------
# Programming languages and runtimes
# ------------------------------------------------------------------------------

brew "ruby"                        # Ruby programming language

# ------------------------------------------------------------------------------
# Version management for languages/tools
# ------------------------------------------------------------------------------

brew "jenv"                        # [verify] Java version management

# ------------------------------------------------------------------------------
# Java/JVM development
# ------------------------------------------------------------------------------

brew "maven"                       # Build system for Java
cask "temurin@8"                   # Eclipse Temurin JDK 8
cask "temurin@11"                  # Eclipse Temurin JDK 11
cask "temurin@17"                  # Eclipse Temurin JDK 17
cask "temurin@21"                  # Eclipse Temurin JDK 21
cask "temurin@25"                  # Eclipse Temurin JDK 25

# ------------------------------------------------------------------------------
# Cloud, Kubernetes and infrastructure
# ------------------------------------------------------------------------------

brew "awscli"                      # AWS command line tools
brew "azure-cli"                   # Azure command line tools
brew "Azure/kubelogin/kubelogin"   # Azure Kubernetes login
brew "kubernetes-cli"              # [verify cmd:kubectl] kubectl
brew "kubectx"                     # Switch between k8s contexts/namespaces
brew "helm"                        # Kubernetes package management

# ------------------------------------------------------------------------------
# Security and passwords
# ------------------------------------------------------------------------------

brew "pass"                        # Unix password store (GPG-based)
brew "pinentry-mac"                # GPG PIN dialog for macOS

# ------------------------------------------------------------------------------
# Mobile development
# ------------------------------------------------------------------------------

cask "android-studio"              # Android IDE

# ------------------------------------------------------------------------------
# Miscellaneous CLI tools
# ------------------------------------------------------------------------------

brew "displayplacer"               # Control display resolution/placement
brew "anomalyco/tap/opencode"      # [self-updates] AI-powered coding agent for the terminal
brew "navikt/tap/cplt"             # Kernel-level sandbox for AI agents

# ------------------------------------------------------------------------------
# Casks – Browsers
# ------------------------------------------------------------------------------

cask "arc"                         # [self-updates] Arc browser
cask "firefox"                     # Mozilla Firefox
cask "google-chrome"               # Google Chrome
cask "helium-browser"              # Lightweight Chromium browser
cask "zen"                         # Zen Browser

# ------------------------------------------------------------------------------
# Casks – Communication
# ------------------------------------------------------------------------------

cask "discord"                     # Chat and voice for gaming/community
cask "microsoft-teams"             # Microsoft Teams
cask "signal"                      # Encrypted messaging app

# ------------------------------------------------------------------------------
# Casks – Productivity and notes
# ------------------------------------------------------------------------------

cask "1password"                   # [self-updates] Password manager
cask "1password-cli"               # 1Password CLI
cask "tuna"                        # [self-updates] Modern app launcher (Quicksilver-inspired)
cask "notion"                      # Notes and wiki
cask "rectangle"                   # Window placement with the keyboard
cask "jordanbaird-ice"             # Hide icons in the menu bar

# ------------------------------------------------------------------------------
# Casks – Development
# ------------------------------------------------------------------------------

cask "docker-desktop"              # Docker Desktop GUI
cask "claude-code@latest"          # Anthropic's coding agent for the terminal
cask "intellij-idea"               # JetBrains Java/Kotlin IDE
cask "jetbrains-toolbox"           # Manage JetBrains tools
cask "visual-studio-code"          # Microsoft VS Code
cask "sublime-text"                # Sublime Text editor
cask "postman"                     # API testing
cask "keystore-explorer"           # GUI for Java keystores
cask "figma"                       # Design and prototyping

# ------------------------------------------------------------------------------
# Casks – Media and entertainment
# ------------------------------------------------------------------------------

cask "vlc"                         # Media player (plays everything)
cask "steam"                       # Gaming platform
cask "notunes"                     # Stop Apple Music from opening itself

# ------------------------------------------------------------------------------
# Casks – Tools and miscellaneous
# ------------------------------------------------------------------------------

cask "grandperspective"            # Visualize disk usage
cask "remarkable"                  # reMarkable tablet sync
cask "font-monaspace"              # Monaspace Neon
cask "font-jetbrains-mono-nerd-font" # JetBrains Mono with Nerd Font icons
cask "font-iosevka-nerd-font"        # Iosevka with Nerd Font icons
cask "font-symbols-only-nerd-font" # Nerd Font icons as a fallback for fonts without them (e.g. Monaspace)
