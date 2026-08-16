{
  description = "Packages managed by the dotfiles repository";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { nixpkgs, ... }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
      managedPackages = [
        # Shell and terminal
        { package = pkgs.bash; verify-command = "bash"; } # Modern Bash
        { package = pkgs.atuin; verify-command = "atuin"; } # Shell history with search and sync
        { package = pkgs.direnv; verify-command = "direnv"; } # Per-directory environment variables
        { package = pkgs.starship; verify-command = "starship"; } # Shell prompt
        { package = pkgs.tmux; verify-command = "tmux"; } # Terminal multiplexer
        { package = pkgs.neovim; verify-command = "nvim"; } # Text editor
        { package = pkgs.carapace; verify-command = "carapace"; } # Shell completions
        { package = pkgs.tuxedo; verify-command = "tuxedo"; } # Keyboard-driven terminal UI for todo.txt
        { package = pkgs.fzf; verify-command = "fzf"; } # Fuzzy finder
        { package = pkgs.zoxide; verify-command = "zoxide"; } # Smarter cd based on directory history
        { package = pkgs.zsh-autosuggestions; } # Autosuggestions in zsh
        { package = pkgs.zsh-syntax-highlighting; } # Syntax highlighting in zsh

        # Programming languages and runtimes
        { package = pkgs.fnm; verify-command = "fnm"; } # Per-project Node versions
        { package = pkgs.go; verify-command = "go"; } # Go programming language
        { package = pkgs.kotlin; verify-command = "kotlin"; } # Kotlin programming language
        { package = pkgs.ktlint; verify-command = "ktlint"; } # Kotlin linter and formatter
        { package = pkgs.maven; verify-command = "mvn"; } # Java build system
        { package = pkgs.python313; verify-command = "python3"; } # Default Python for the REPL and simple scripts
        { package = pkgs.uv; verify-command = "uv"; } # Python versions, project environments and dependencies

        # Cloud, Kubernetes and infrastructure
        { package = pkgs.kubelogin; verify-command = "kubelogin"; } # Azure Kubernetes login
        { package = pkgs.kubectl; verify-command = "kubectl"; } # Kubernetes command line client
        { package = pkgs.kubectx; verify-command = "kubectx"; } # Switch between Kubernetes contexts
        { package = pkgs.kubernetes-helm; verify-command = "helm"; } # Kubernetes package management

        # Database
        { package = pkgs.flyway; verify-command = "flyway"; } # Database migration
        { package = pkgs.postgresql_18; verify-command = "psql"; } # PostgreSQL client tools

        # Mobile development
        { package = pkgs.cocoapods; verify-command = "pod"; } # iOS dependency management
        { package = pkgs.maestro; verify-command = "maestro"; } # Mobile UI testing and automation

        # Git and version control
        { package = pkgs.git; verify-command = "git"; } # Version control
        { package = pkgs.gh; verify-command = "gh"; } # GitHub CLI
        { package = pkgs.lazygit; verify-command = "lazygit"; } # Terminal UI for Git
        { package = pkgs.delta; verify-command = "delta"; } # Nicer Git diffs
        { package = pkgs.bfg-repo-cleaner; verify-command = "bfg"; } # Clean up Git history
        { package = pkgs.shellcheck; verify-command = "shellcheck"; } # Static analysis for shell scripts

        # File tools and search
        { package = pkgs.ack; verify-command = "ack"; } # Search source code
        { package = pkgs.bat; verify-command = "bat"; } # cat with syntax highlighting
        { package = pkgs.chafa; verify-command = "chafa"; } # Image preview for fzf-preview.sh
        { package = pkgs.eza; verify-command = "eza"; } # Modern ls
        { package = pkgs.exiftool; verify-command = "exiftool"; } # Read and write metadata in media files
        { package = pkgs.fd; verify-command = "fd"; } # Modern find
        { package = pkgs.ripgrep; verify-command = "rg"; } # Fast text search
        { package = pkgs.timg; verify-command = "timg"; } # Show images and video in the terminal
        { package = pkgs.tree; verify-command = "tree"; } # Show directory structure as a tree
        { package = pkgs.cloc; verify-command = "cloc"; } # Count lines of code per language
        { package = pkgs.dust; verify-command = "dust"; } # Visual disk usage
        { package = pkgs.peco; verify-command = "peco"; } # Interactive filtering

        # Download and network tools
        { package = pkgs.curl; verify-command = "curl"; } # HTTP client
        { package = pkgs.wget; verify-command = "wget"; } # Download files
        { package = pkgs.yt-dlp; verify-command = "yt-dlp"; } # Download video

        # JSON, YAML and data processing
        { package = pkgs.jq; verify-command = "jq"; } # JSON processing
        { package = pkgs.yq-go; verify-command = "yq"; } # YAML processing
        { package = pkgs.yamllint; verify-command = "yamllint"; } # YAML linter
        { package = pkgs.jsonnet; verify-command = "jsonnet"; } # Templating for JSON/YAML

        # Documentation and text
        { package = pkgs.asciinema; verify-command = "asciinema"; } # Record terminal sessions

        # Miscellaneous CLI tools
        { package = pkgs.btop; verify-command = "btop"; } # Resource monitor
        { package = pkgs.cbonsai; verify-command = "cbonsai"; } # Bonsai animation in the terminal
        { package = pkgs.cmatrix; verify-command = "cmatrix"; } # Matrix animation in the terminal
        { package = pkgs.glow; verify-command = "glow"; } # Render Markdown in the terminal
        { package = pkgs.macchina; verify-command = "macchina"; } # System information in the terminal
        { package = pkgs.pastel; verify-command = "pastel"; } # Color tool
        { package = pkgs.tealdeer; verify-command = "tldr"; } # Simplified man pages
        { package = pkgs.terminal-notifier; verify-command = "terminal-notifier"; } # Send macOS notifications from the terminal
        { package = pkgs.unixtools.watch; verify-command = "watch"; } # Run a command repeatedly
      ];
      commandManifest = pkgs.writeTextDir "share/dotfiles/nix-commands" (
        nixpkgs.lib.concatStringsSep "\n" (
          map (item: item.verify-command) (builtins.filter (item: item ? verify-command) managedPackages)
        ) + "\n"
      );
      zshPlugins = pkgs.runCommand "dotfiles-zsh-plugins" { } ''
        mkdir -p $out/share/dotfiles/zsh-plugins
        ln -s ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
          $out/share/dotfiles/zsh-plugins/zsh-autosuggestions.zsh
        ln -s ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
          $out/share/dotfiles/zsh-plugins/zsh-syntax-highlighting.zsh
      '';
    in
    {
      packages.${system}.default = pkgs.buildEnv {
        name = "dotfiles-packages";
        paths = map (item: item.package) managedPackages ++ [ commandManifest zshPlugins ];
      };
    };
}
