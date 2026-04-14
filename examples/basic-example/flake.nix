{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    nixmesh = {
      url = "path:../../";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixmesh,
      ...
    }:
    {
      modules = [ nixmesh.modules.default ];

      nixosModules = nixmesh.lib.mkMesh {
        cluster = {
          # meshSubnet = "10.0.0.0/16";
          volumes = import ./volumes.nix { inherit nixmesh; };
          nodes = import ./nodes.nix { inherit nixmesh; };
          jobs = import ./jobs.nix { inherit nixmesh; };
          ingress = import ./ingress.nix { inherit nixmesh; };
        };

        # secrets = {
        #   backend = "sops-nix"; # default value, also allows "external"
        #   secretsFile = ./secrets.yaml;
        #   format = "yaml";

        ## example with external
        # backend = "external";
        # loadSecrets = { config, lib, pkgs }: {
        # ## normal configuration.nix schema
        # }
        #
        # example of secret fetcher
        # fetchSecret = name: { config, lib, pkgs }: config.sops.secrets.${name}.path
        # };

        # extraNixosConfig = {
        #   # pass through for all nixos configurations
        #   ## i.e. loading in sops-nix, or other modules to use elsewhere
        # };
      };
    };
}
