{
  description = "Packages managed by the dotfiles repository";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { nixpkgs, ... }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
      managedPackages = [
        { package = pkgs.bat; verify-command = "bat"; }
        { package = pkgs.fd; verify-command = "fd"; }
        { package = pkgs.jq; verify-command = "jq"; }
        { package = pkgs.tree; verify-command = "tree"; }
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
