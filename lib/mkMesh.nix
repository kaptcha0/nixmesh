{
  lib,
  coreModules,
  ...
}:
spec:
let
  nixmesh =
    (lib.evalModules {
      modules = coreModules ++ [
        { nixmesh = spec; }
      ];
    }).config.nixmesh;
  mkJobs = import ./mkJobs.nix;
  mkNodes = import ./mkNodes.nix;
  mkVolumes = import ./mkVolumes.nix;
  mkIngress = import ./mkIngress.nix;
in
{
  nixosConfigs = lib.mapAttrs (
    nodeName: nodeConfig:
    lib.nixosSystem {
      system = nodeConfig.hostPlatform;

      specialArgs = {
        inherit
          nodeName
          nixmesh
          spec
          coreModules
          ;
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
  ) nixmesh.nodes;
}
