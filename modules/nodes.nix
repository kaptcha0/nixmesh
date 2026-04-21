{ lib, ... }:
let
  inherit (lib) mkOption types;
  node = types.submodule {
    options = {
      roles = mkOption {
        type = types.listOf (
          types.enum [
            "master"
            "worker"
            "ingress"
          ]
        );
        default = [ "worker" ];
        description = "Roles of the node, used for targeting deployments.";
      };

      hostPlatform = mkOption {
        type = types.enum [
          "x86_64-linux"
          "aarch64-linux"
        ];
        default = "x86_64-linux";
        description = "Architecture of the node.";
      };

      connection = {
        ip = mkOption {
          type = types.str;
          description = "IP address of the node for ssh connection and as default endpoint ip.";
        };
        port = mkOption {
          type = types.int;
          default = 22;
          description = "SSH port of the node.";
        };
        user = mkOption {
          type = types.str;
          default = "nixmesh";
          description = "SSH user for connecting to the node.";
        };
        sshPublicKeys = mkOption {
          type = types.listOf types.str;
          description = "Public keys for ssh connection to push deployment (if empty, will try to connect normally).";
          default = [ ];
        };
        tags = mkOption {
          type = types.listOf types.str;
          description = "Tags for the node, used for targeting deployments.";
        };
      };

      hardware = {
        ram = mkOption {
          type = types.int;
          description = "RAM of the node in Mb.";
        };
        cpuCores = mkOption {
          type = types.int;
          description = "Number of CPU cores of the node.";
        };
        gpu = mkOption {
          type = types.bool;
          default = false;
          description = "Whether the node has a GPU.";
        };
        disks = mkOption {
          type = types.attrsOf (
            types.submodule {
              options = {
                device = mkOption {
                  type = types.str;
                  description = "Mount path of the disk.";
                };
                fsType = mkOption {
                  type = types.enum [
                    "ext4"
                    "xfs"
                    "btrfs"
                  ];
                  default = "ext4";
                  description = "Filesystem format of the disk.";
                };
                label = mkOption {
                  type = types.nullOr types.str;
                  description = "Label for the disk, used for targeting deployments.";
                  default = null;
                };
              };
            }
          );
          description = "Disks of the node.";
        };
      };

      wireguard = {
        meshIp = mkOption {
          type = types.str;
          description = "IP address of the node within the mesh network.";
        };

        publicKey = mkOption {
          type = types.str;
          description = "Public key for the node in the mesh network.";
        };

        privateKeyFile = mkOption {
          type = types.str;
          description = "Path to the private key file for the node in the mesh network";
        };

        endpoint = {
          ip = mkOption {
            type = types.nullOr types.str;
            description = "Public IP address of the node for mesh network endpoint. Defaults to the connection IP.";
            default = null;
          };

          port = mkOption {
            type = types.int;
            default = 51820;
            description = "Public port of the node for mesh network endpoint.";
          };
        };

      };

      extraConfig = mkOption {
        type = types.deferredModule;
        description = "Extra configuration for the node, merged with the main configuration. Can be used to set any valid NixOS configuration options on a per-node basis.";
        default = { ... }: { };
      };

      extraModules = mkOption {
        type = types.listOf types.deferredModule;
        description = "Extra NixOS modules for the node, merged with the main configuration. Can be used to set any valid NixOS configuration options on a per-node basis.";
        default = [ ];
      };
    };
  };
in
{
  options.nixmesh.cluster.nodes = mkOption {
    type = types.attrsOf node;
    default = { };
  };
}
