{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      rEnv = pkgs.rWrapper.override {
        packages = with pkgs.rPackages; [
          tidyverse
        ];
      };
    in
    {
      devShells.${system} = {
        default = pkgs.mkShell {
          packages = [
            rEnv
            pkgs.texliveFull
            pkgs.just
            pkgs.gcc
          ];
        };
        pcad = pkgs.mkShell {
          buildInputs = with pkgs; [
            gcc
            just
          ];
        };
      };
    };
}
