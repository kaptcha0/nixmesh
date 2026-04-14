{ lib, coreModules, ... }:
meshConfig:
let
  eval = lib.evalModules {
    modules = coreModules ++ [
      { nixmesh = meshConfig; }
    ];
  };
in
eval.config.nixmesh
