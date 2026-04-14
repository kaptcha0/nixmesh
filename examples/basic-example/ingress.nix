{ nixmesh, ... }:
{
  backend = "traefik";

  staticEntryPoints = {
    nextcloud = {
      port = 80880;
      protocol = "tcp";
    };
  };

  middlewares = {
    rateLimit = {
      type = "rateLimit";
      config = {
        burst = 50;
        average = 100;
      };
    };
  };

  routes = {
    nextcloud-tcp = {
      job = nixmesh.lib.getJob "nextcloud";
      port = 8081;
      entryPoint = "nextcloud";
      middlewares = [
        "rateLimit"
      ];
    };
  };
}
