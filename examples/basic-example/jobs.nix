{ nixmesh, ... }:
{
  echo =
    let
      serverPort = 8080;
    in
    {
      container = "ealen/echo-server:latest";
      prefersNode = nixmesh.lib.getNode "node1";

      ports = [ serverPort ];

      envVars = {
        PORT = serverPort;
        ENABLE__HTTP = false;
      };

      volume = {
        external-store = {
          path = "/var/www/html";
          hostPath = (nixmesh.lib.getVolumePath "nfs") + "/external-store";
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

    container = # completely declarative configuration
      {
        nixmesh,
        ...
      }:
      {
        services.nextcloud = {
          enable = true;
          hostName = "nextcloud.tld";
          database.createLocally = true;

          config = {
            dbtype = "pgsql";
            adminpassFile = nixmesh.lib.getSecret "pgsql-pass";
          };
        };
      };

  };
}
