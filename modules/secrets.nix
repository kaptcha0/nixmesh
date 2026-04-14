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

    fetchSecret = mkOption {
      type = types.deferredModule;
      default = null;
      description = "Function to fetch a specific secret for external backend. Receives the secret name and { config, lib, pkgs } and should return the secret value.";
    };
  };
}
