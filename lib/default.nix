{ ... }@inputs:
let
  mkMesh = import ./mkMesh.nix inputs;
  getNode = import ./getNode.nix inputs;
  getVolumePath = import ./getVolumePath.nix inputs;
  getJob = import ./getJob.nix inputs;
  getSecret = import ./getSecret.nix inputs;
in
{
  inherit
    mkMesh
    getNode
    getVolumePath
    getJob
    getSecret
    ;
}
