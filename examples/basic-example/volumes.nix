{ cluster, ... }:
let
  secrets = cluster.secrets;
in
{
  nfs = {
    type = "nfs";
    hostPath = "/mnt/nfs";
    target = "nas.cluster.local";
    remotePath = "/cluster-volumes/nfs";
  };

  smb = {
    type = "smb";
    hostPath = "/mnt/smb";
    target = "nas.cluster.local";
    remotePath = "/cluster-volumes/smb";

    username = "test-user";
    passwordFile = secrets.smb-password;
  };
}
