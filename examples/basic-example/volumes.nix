{ nixmesh }:
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

    credentials = {
      username = "test-user";
      passwordFile = nixmesh.lib.getSecret "smb-password";
    };
  };
}
