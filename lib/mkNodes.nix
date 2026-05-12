{
  nodeName,
  nixmesh,
  spec,
  coreModules,
  lib,
  ...
}@inputs:
let
  cfg =
    if builtins.isFunction spec.nodes.${nodeName} then
      (lib.evalModules {
        modules = coreModules ++ [
          {
            nixmesh.nodes.${nodeName} = (spec.nodes.${nodeName} inputs);
          }
        ];
      }).config.nixmesh.nodes.${nodeName}
    else
      nixmesh.nodes.${nodeName};
  isMaster = builtins.elem "master" cfg.roles;
  isIngress = builtins.elem "ingress" cfg.roles;
in
{
  ## consul configuration
  nixpkgs.config.allowUnfree = true;

  services.consul = {
    enable = true;
    webUi = isMaster;

    interface = {
      bind = "wg0";
      advertise = "wg0";
    };

    extraConfig = {
      server = isMaster;
      datacenter = "nixmesh";
      ui_config.enabled = true;

      retry_join = lib.mapAttrsToList (
        peerName: peerConfig: "${peerConfig.wireguard.meshIp}"
      ) nixmesh.nodes;

      bootstrap_expect = lib.length (
        lib.filter (peerConfig: builtins.elem "master" peerConfig.roles) nixmesh.nodes
      );
    };
  };

  ## wireguard configuration
  networking.nftables.enable = true;
  networking.hostName = nodeName;

  networking.nat = {
    enable = true;
    enableIPv6 = true;
    externalInterface = "eth0";
    internalInterfaces = [ "wg0" ];
  };

  networking.firewall.interfaces."wg0" = {
    allowedTCPPorts = [
      8600 # consul DNS
      8301 # consul gossip LAN
    ]
    ++ lib.optionals isMaster [
      8503 # consul GRPC API
      8300 # consul internal server communication
      8302 # consul gossip WAN
    ];

    allowedUDPPorts = [
      8600 # consul DNS
      8301 # consul gossip LAN
    ];
  };

  networking.firewall = {
    allowedTCPPorts = [
      8500 # consul HTTP API
    ];

    allowedUDPPorts = [
      51820 # wireguard
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
    ) nixmesh.nodes;
  };

  ## basic system configuration

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
    settings.KbdInteractiveAuthentication = false;
    settings.PermitRootLogin = "no";
  };

  users.users.${cfg.connection.user} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = cfg.connection.sshPublicKeys;
  };

  security.sudo.wheelNeedsPassword = false;

  nix = {
    settings.trusted-users = [ cfg.connection.user ];

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  boot.loader.systemd-boot.enable = true;

  fileSystems = lib.mapAttrs (diskName: diskConfig: {
    device = diskConfig.device;
    fsType = diskConfig.fsType;
    label = diskConfig.label;
  }) cfg.hardware.disks;

  system.stateVersion = "26.05";
}
