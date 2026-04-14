{ lib, ... }:
let
  inherit (lib) mkOption types;
  entryPoint = types.submodule {
    options = {
      port = mkOption {
        type = types.int;
        description = "Port number for this entry point.";
      };
      protocol = mkOption {
        type = types.enum [
          "tcp"
          "udp"
          "http"
        ];
        description = "Protocol for this entry point (tcp, udp, or http).";
      };
    };
  };

  middleware = types.submodule {
    options = {
      type = mkOption {
        type = types.str;
        description = "Middleware type (e.g., rateLimit, basicAuth).";
      };

      config = mkOption {
        type = types.attrs;
        description = "Configuration options for the middleware.";
      };
    };
  };

  route = types.submodule {
    options = {
      job = mkOption {
        type = types.str;
        description = "Job name to route to.";
      };
      port = mkOption {
        type = types.int;
        description = "Port on the job container to route to.";
      };
      entryPoint = mkOption {
        type = types.str;
        description = "Entry point name to bind this route to.";
      };
      middlewares = mkOption {
        type = types.listOf types.str;
        description = "List of middleware names to apply to this route.";
      };
    };
  };
in
{
  options.nixmesh.cluster.ingress = {
    backend = mkOption {
      type = types.enum [ "traefik" ];
      description = "Ingress backend to use (currently only traefik).";
    };

    staticEntryPoints = mkOption {
      type = types.attrsOf entryPoint;
      default = { };
      description = "Static entry points for network traffic.";
    };

    middlewares = mkOption {
      type = types.attrsOf middleware;
      default = { };
      description = "Middleware configurations for request processing.";
    };

    routes = mkOption {
      type = types.attrsOf route;
      default = { };
      description = "Routing rules mapping entry points to jobs.";
    };
  };
}
