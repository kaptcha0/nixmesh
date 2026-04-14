{
  description = "nixmesh";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
      ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      perSystem =
        {
          pkgs,
          ...
        }:
        {
          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              nixd
              statix
              deadnix
              nixfmt
            ];
          };

          formatter = pkgs.nixfmt;
        };
      flake = {
        lib = import ./lib {
          lib = inputs.nixpkgs.lib;
          coreModules = [ ./modules ];
        };

        nixosModules.default = ./modules;
      };
    };
}
