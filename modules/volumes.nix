{ lib, ... }:
let
  inherit (lib) mkOption types;
  credentials = types.submodule {
    options = {
      username = mkOption {
        type = types.str;
        description = "Username for volume authentication.";
      };
      passwordFile = mkOption {
        type = types.str;
        description = "Path to a file containing the password for volume authentication.";
      };
    };
  };
  volume = types.submodule {
    options = {
      type = mkOption {
        type = types.enum [
          "nfs"
          "smb"
        ];
        description = "Type of volume (e.g., nfs, smb).";
      };
      hostPath = mkOption {
        type = types.str;
        description = "Local path on the host to mount.";
      };
      target = mkOption {
        type = types.str;
        description = "Target hostname or IP for the volume.";
      };
      remotePath = mkOption {
        type = types.str;
        description = "Remote path on the target to mount.";
      };

      credentials = mkOption {
        type = types.nullOr credentials;
        default = null;
        description = "Optional credentials for the volume (e.g., username, password).";
      };
    };
  };
in
{
  options.nixmesh.cluster.volumes = mkOption {
    type = types.attrsOf volume;
    default = { };
    description = "Cluster-wide volume definitions.";
  };
}
