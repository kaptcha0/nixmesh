{
  lib,
  coreModules,
  ...
}:
meshConfig:
let
  _ = lib.evalModules {
    modules = coreModules ++ [
      { nixmesh = meshConfig; }
    ];
  };
  mkJobs = import ./mkJob.nix;
  mkNode = import ./mkNodes.nix;
  mkVolumes = import ./mkVolumes.nix;
  mkIngress = import ./mkIngress.nix;
in
lib.mapAttrs (
  nodeName: nodeConfig:
  lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {
      inherit nodeName;
      nixmesh = meshConfig;
    };
    modules = [
      (inputs: mkIngress inputs)
      (inputs: mkJobs inputs)
      (inputs: mkNode inputs)
      (inputs: mkVolumes inputs)

      meshConfig.secrets.loadSecrets
    ];
  }
) meshConfig.cluster.nodes
