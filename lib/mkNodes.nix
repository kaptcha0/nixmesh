{
  nodeName,
  nixmesh,
  pkgs,
  ...
}:
let
  cfg = nixmesh.cluster.nodes.${nodeName};
  isMaster = builtins.elem "master" cfg.roles;
in
{
  nixpkgs.config.allowUnfree = true;
  services.consul = {
    enable = true;
    webUi = isMaster;
  };

  environment.systemPackages = with pkgs; [
    vim
    helix
    ssh-to-age
  ];

  boot.isContainer = true;
  systemd.suppressedSystemUnits = [
    "dev-mqueue.mount"
    "sys-kernel-debug.mount"
    "sys-fs-fuse-connections.mount"
  ];

  security.sudo.wheelNeedsPassword = false;

  nix = {
    settings.trusted-users = [ "nixos" ];

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  users.users.nixos = {
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

  system.stateVersion = "26.05";
}
