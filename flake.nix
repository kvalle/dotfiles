{
  description = "Packages managed by the dotfiles repository";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { nixpkgs, ... }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system}.default = pkgs.buildEnv {
        name = "dotfiles-packages";
        paths = with pkgs; [
          bat
        ];
      };
    };
}
