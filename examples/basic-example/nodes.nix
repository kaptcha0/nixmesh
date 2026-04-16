{ inputs, ... }:
let
  extraModules = [
    inputs.sops-nix.nixosModules.sops
  ];
in
rec {
  node1 = rec {
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
      user = "testUser"; # defaults to root
      sshPublicKey = "xyz_..."; # public key for ssh connection to push deployment (if empty, will try to connect normally)
    };

    hardware = {
      ram = 16 * 1024; # Mb
      cpuCores = 4;
      gpu = false;
    };

    wireguard = {
      meshIp = "10.0.0.1";
      publicKey = "abcd_...";
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
    };

    wireguard = {
      meshIp = node1.wireguard.meshIp + "1";
      publicKey = "abcd_...";
    };
  };
}
