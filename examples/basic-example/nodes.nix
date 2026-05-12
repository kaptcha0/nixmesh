{ inputs, ... }:
let
  extraModules = [
    inputs.sops-nix.nixosModules.sops
  ];
in
{
  node1 =
    { config, ... }:
    rec {
      inherit extraModules;

      roles = [
        "master"
        "ingress"
        "worker"
      ]; # defaults to ["worker"]

      connection = {
        # mandatory
        ip = "192.168.1.50"; # mandatory
        port = 222; # defaults to 22
        user = "testUser"; # defaults to nixmesh
        sshPublicKeys = [ "xyz_..." ]; # public key for ssh connection to push deployment (if empty, will try to connect normally)
      };

      hardware = {
        ram = 16 * 1024; # Mb
        cpuCores = 4;
        gpu = false;

        disks."/".device = "/dev/sda1";
      };

      wireguard = {
        meshIp = "10.0.0.1";
        publicKey = "abcd_...";
        privateKeyFile = config.sops.secrets."node1-wg-private-key".path;
        endpoint = {
          # here are the default values
          ip = connection.ip;
          port = 51820;
        };
      };
    };

  node2 = {
    inherit extraModules;

    connection = {
      # mandatory
      ip = "192.168.1.51"; # mandatory
    };

    hardware = {
      ram = 16 * 1024; # Mb
      cpuCores = 8;
      gpu = true;
      disks."/".device = "/dev/sda1";
    };

    wireguard = {
      meshIp = "10.0.0.2";
      publicKey = "abcd_...";
      privateKeyFile = "/path/to/private/key";
    };
  };
}
