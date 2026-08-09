{
  description = "Packages managed by the dotfiles repository";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { nixpkgs, ... }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
      managedPackages = [
        # Shell og terminal
        { package = pkgs.atuin; verify-command = "atuin"; } # Shell-historikk med søk og synk
        { package = pkgs.direnv; verify-command = "direnv"; } # Miljøvariabler per katalog
        { package = pkgs.starship; verify-command = "starship"; } # Shell-prompt
        { package = pkgs.tmux; verify-command = "tmux"; } # Terminal multiplexer
        { package = pkgs.neovim; verify-command = "nvim"; } # Teksteditor
        { package = pkgs.carapace; verify-command = "carapace"; } # Shell-completions
        { package = pkgs.tuxedo; verify-command = "tuxedo"; } # Tastaturdrevet terminal-UI for todo.txt

        # Programmeringsspråk og runtime
        { package = pkgs.go; verify-command = "go"; } # Go-programmeringsspråk
        { package = pkgs.kotlin; verify-command = "kotlin"; } # Kotlin-programmeringsspråk
        { package = pkgs.ktlint; verify-command = "ktlint"; } # Kotlin-linter og formatter
        { package = pkgs.python313; verify-command = "python3"; } # Standard-Python for REPL og enkle skript
        { package = pkgs.uv; verify-command = "uv"; } # Python-versjoner, prosjektmiljøer og avhengigheter

        # Database
        { package = pkgs.flyway; verify-command = "flyway"; } # Database-migrering
        { package = pkgs.postgresql_18; verify-command = "psql"; } # PostgreSQL-klientverktøy

        # Mobilutvikling
        { package = pkgs.cocoapods; verify-command = "pod"; } # iOS-avhengighetshåndtering
        { package = pkgs.maestro; verify-command = "maestro"; } # Mobil UI-testing og automatisering

        # Git og versjonskontroll
        { package = pkgs.git; verify-command = "git"; } # Versjonskontroll
        { package = pkgs.gh; verify-command = "gh"; } # GitHub CLI
        { package = pkgs.lazygit; verify-command = "lazygit"; } # Terminal-UI for Git
        { package = pkgs.delta; verify-command = "delta"; } # Penere Git-diff
        { package = pkgs.bfg-repo-cleaner; verify-command = "bfg"; } # Rydd Git-historikk

        # Filverktøy og søk
        { package = pkgs.ack; verify-command = "ack"; } # Søk i kildekode
        { package = pkgs.bat; verify-command = "bat"; } # cat med syntaksutheving
        { package = pkgs.chafa; verify-command = "chafa"; } # Bilde-preview for fzf-preview.sh
        { package = pkgs.eza; verify-command = "eza"; } # Moderne ls
        { package = pkgs.exiftool; verify-command = "exiftool"; } # Les og skriv metadata i mediefiler
        { package = pkgs.fd; verify-command = "fd"; } # Moderne find
        { package = pkgs.ripgrep; verify-command = "rg"; } # Raskt tekstsøk
        { package = pkgs.timg; verify-command = "timg"; } # Vis bilder og video i terminalen
        { package = pkgs.tree; verify-command = "tree"; } # Vis mappestruktur som tre
        { package = pkgs.cloc; verify-command = "cloc"; } # Tell kodelinjer per språk
        { package = pkgs.dust; verify-command = "dust"; } # Visuell diskbruk
        { package = pkgs.peco; verify-command = "peco"; } # Interaktiv filtrering

        # Nedlasting og nettverksverktøy
        { package = pkgs.curl; verify-command = "curl"; } # HTTP-klient
        { package = pkgs.wget; verify-command = "wget"; } # Last ned filer
        { package = pkgs.yt-dlp; verify-command = "yt-dlp"; } # Last ned video

        # JSON, YAML og databehandling
        { package = pkgs.jq; verify-command = "jq"; } # JSON-prosessering
        { package = pkgs.yq-go; verify-command = "yq"; } # YAML-prosessering
        { package = pkgs.yamllint; verify-command = "yamllint"; } # YAML-linter
        { package = pkgs.jsonnet; verify-command = "jsonnet"; } # Templating for JSON/YAML

        # Dokumentasjon og tekst
        { package = pkgs.asciinema; verify-command = "asciinema"; } # Ta opptak av terminalsesjoner

        # Diverse CLI-verktøy
        { package = pkgs.btop; verify-command = "btop"; } # Ressursmonitor
        { package = pkgs.cbonsai; verify-command = "cbonsai"; } # Bonsai-animasjon i terminalen
        { package = pkgs.cmatrix; verify-command = "cmatrix"; } # Matrix-animasjon i terminalen
        { package = pkgs.glow; verify-command = "glow"; } # Vis Markdown i terminalen
        { package = pkgs.macchina; verify-command = "macchina"; } # Systeminformasjon i terminalen
        { package = pkgs.pastel; verify-command = "pastel"; } # Fargeverktøy
        { package = pkgs.tealdeer; verify-command = "tldr"; } # Forenklede man-sider
        { package = pkgs.terminal-notifier; verify-command = "terminal-notifier"; } # Send macOS-varsler fra terminalen
        { package = pkgs.unixtools.watch; verify-command = "watch"; } # Kjør kommando gjentatte ganger
      ];
      commandManifest = pkgs.writeTextDir "share/dotfiles/nix-commands" (
        nixpkgs.lib.concatStringsSep "\n" (map (item: item.verify-command) managedPackages) + "\n"
      );
    in
    {
      packages.${system}.default = pkgs.buildEnv {
        name = "dotfiles-packages";
        paths = map (item: item.package) managedPackages ++ [ commandManifest ];
      };
    };
}
