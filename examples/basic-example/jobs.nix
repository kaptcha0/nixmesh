{ cluster, ... }:
let
  volumes = cluster.config.volumes;
  nodes = cluster.config.nodes;
  secrets = cluster.secrets;
in
{
  echo =
    let
      serverPort = 8080;
    in
    {
      container.image = "ealen/echo-server:latest";
      prefersNode = nodes.node1;

      ports = [ serverPort ];

      envVars = {
        PORT = serverPort;
        ENABLE__HTTP = false;
      };

      volume = {
        external-store = {
          path = "/var/www/html";
          hostPath = volumes.nfs + "/external-store";
        };
      };

      healthCheck = {
        http = {
          endpoint = "http://localhost:${toString serverPort}/healthcheck";
          method = "POST";
          expectedStatus = 200;
        };

        # examples for tcp and udp
        # tcp.endpoint = "127.0.0.1:${serverPort}";
        # udp.endpoint = "127.0.0.1:${serverPort}";
      };

      ingress.http = {
        default = {
          host = "acme.com";
          port = 80;
          path = "/echo";
          tls = false;
        };
      };
    };

  nextcloud = {
    healthCheck.http.endpoint = "http://localhost:80/healthcheck";

    requires = {
      memory = 2048; # in MB
      cpuCores = 2; # cpu cores
    };

    ingress.http = {
      byPath = {
        host = "acme.com";
        port = 80;
        path = "/nextcloud";
        tls = true;
      };

      byHost = {
        host = "nextcloud.acme.com";
        port = 80;
        tls = true;
      };
    };

    container.config = # completely declarative configuration
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        services.nextcloud = {
          enable = true;
          hostName = "nextcloud.tld";
          database.createLocally = true;

          config = {
            dbtype = "pgsql";
            adminpassFile = secrets.pgsql-pass;
          };
        };
      };

  };
}
