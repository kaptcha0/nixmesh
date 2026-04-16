{
  lib,
  coreModules,
  ...
}:
meshConfig:
let
  nixmesh =
    (lib.evalModules {
      modules = coreModules ++ [
        { nixmesh = meshConfig; }
      ];
    }).config.nixmesh;
  mkJobs = import ./mkJobs.nix;
  mkNodes = import ./mkNodes.nix;
  mkVolumes = import ./mkVolumes.nix;
  mkIngress = import ./mkIngress.nix;
in
lib.mapAttrs (
  nodeName: nodeConfig:
  lib.nixosSystem {
    system = nodeConfig.hostPlatform;

    specialArgs = {
      inherit nodeName nixmesh;
    };

    modules = [
      mkIngress
      mkJobs
      mkNodes
      mkVolumes

      nixmesh.secrets.loadSecrets
      nodeConfig.extraConfig
    ]
    ++ nodeConfig.extraModules;
  }
) nixmesh.cluster.nodes
