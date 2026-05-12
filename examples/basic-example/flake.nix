{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixmesh = {
      url = "path:../../";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixmesh,
      ...
    }@inputs:
    let
      cluster = nixmesh.lib.mkMesh {
        volumes = import ./volumes.nix { inherit nixmesh; };
        nodes = import ./nodes.nix { inherit nixmesh inputs; };
        jobs = import ./jobs.nix { inherit nixmesh; };
        ingress = import ./ingress.nix { inherit nixmesh; };

        secrets = {
          loadSecrets =
            { ... }:
            {
              sops.defaultSopsFile = ./secrets.sops.yaml;
              sops.secrets.pgsql-pass = { };
              sops.secrets.smb-password = { };
              sops.secrets.node1-wg-private-key = { };
            };
        };
      };
    in
    {
      nixosConfigurations = cluster.nixosConfigs;
    };
}
