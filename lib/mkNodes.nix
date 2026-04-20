{
  nodeName,
  nixmesh,
  lib,
  ...
}@inputs:
let
  cfg = nixmesh.cluster.nodes.${nodeName};
  isMaster = builtins.elem "master" cfg.roles;
  isIngress = builtins.elem "ingress" cfg.roles;
in
{
  nixpkgs.config.allowUnfree = true;

  networking.nat = {
    enable = true;
    enableIPv6 = true;
    externalInterface = "eth0";
    internalInterfaces = [ "wg0" ];
  };

  networking.firewall = {
    allowedTCPPorts = [ ];
    allowedUDPPorts = [
      51820
    ];
  };

  networking.wg-quick.interfaces.wg0 = {
    inherit (cfg.wireguard) privateKeyFile;

    listenPort = 51820;
    address = [ cfg.wireguard.meshIp ];

    peers = lib.mapAttrsToList (
      peerName: peerConfig:
      with peerConfig.wireguard;
      let
        endpointIp = if endpoint.ip != null then endpoint.ip else peerConfig.connection.ip;
      in
      {
        inherit publicKey;
        allowedIPs = [ (meshIp + "/32") ];
        endpoint = "${endpointIp}:${toString endpoint.port}";
        persistentKeepalive = 25;
      }
    ) nixmesh.cluster.nodes;
  };

  security.sudo.wheelNeedsPassword = false;

  nix = {
    settings.trusted-users = [ "nixos" ];

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  users.users.${cfg.connection.user} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = cfg.connection.sshPublicKeys;
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
    settings.KbdInteractiveAuthentication = false;
    settings.PermitRootLogin = "no";
  };

  networking.nftables.enable = true;
  networking.hostName = nodeName;

  boot.loader.systemd-boot.enable = true;

  fileSystems = lib.mapAttrs (diskName: diskConfig: {
    device = diskConfig.device;
    fsType = diskConfig.fsType;
    label = diskConfig.label;
  }) cfg.hardware.disks;

  system.stateVersion = "26.05";
}
