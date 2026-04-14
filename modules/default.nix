{ ... }:
{
  imports = [
    ./ingress.nix
    ./jobs.nix
    ./nodes.nix
    ./secrets.nix
    ./volumes.nix
  ];
}
