{ cluster, ... }:
let
  jobs = cluster.config.jobs;
in
{
  staticEntryPoints = {
    nextcloud = {
      port = 80880;
      protocol = "tcp";
    };
  };

  middlewares = {
    rateLimit = {
      type = "rateLimit";
      burst = 50;
      average = 100;
    };
  };

  routes =
    { entryPoints, middlewares, ... }:
    {
      nextcloud-tcp = {
        job = jobs.nextcloud;
        port = 8081;
        entryPoint = entryPoints.nextcloud;
        middlewares = [
          middlewares.rateLimit
        ];
      };
    };
}
