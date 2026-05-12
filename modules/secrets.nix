{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.nixmesh.secrets = {
    loadSecrets = mkOption {
      type = types.deferredModule;
      default = { };
      description = "Function to load secrets for external backend. Receives { config, lib, pkgs } and should return an attribute set of secrets.";
    };
  };
}
