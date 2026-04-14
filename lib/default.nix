{ ... }@inputs:
let
  mkMesh = import ./mkMesh.nix inputs;
in
{
  inherit mkMesh;
}
