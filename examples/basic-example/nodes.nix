{ cluster, ... }:
let
  nodes = cluster.config.nodes; # can reference other node configuration
in
{
  default = # properties here are merged, with the node-specific configurations taking precedent
    { ... }:
    {
      connection.tags = [ "cluster" ]; # arrays are merged
      extraConfig = {
        time.timeZone = "America/New_York";
      };
    };

  node1 =
    { self, ... }:
    {
      roles = ["master" "ingress" "worker"]; # defaults to ["worker"]

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

      networking = {
        meshIp = "10.0.0.1";
        publicKey = "abcd_...";
        endpoint = {
          # here are the default values
          ip = self.connection.ip;
          port = 51820;
        };
      };
    };
  node2 =
    { ... }:
    {
      connection = {
        # mandatory
        ip = "192.168.1.51"; # mandatory
      };

      hardware = {
        ram = 16 * 1024; # Mb
        cpuCores = 8;
        gpu = true;
      };

      networking = {
        meshIp = nodes.node1.networking.meshIp + "1";
        publicKey = "abcd_...";
      };
    };
}
