{ lib, ... }:
let
  inherit (lib) mkOption types;

  job = types.submodule {
    options = {
      container = mkOption {
        type = types.either types.str types.deferredModule;
        description = "Container image (string) or NixOS module configuration.";
      };

      prefersNode = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Preferred node to schedule this job on.";
      };

      requires = mkOption {
        type = types.nullOr (
          types.submodule {
            options = {
              memory = mkOption {
                type = types.int;
                description = "Minimum required memory in MB.";
              };
              cpuCores = mkOption {
                type = types.int;
                description = "Minimum required CPU cores.";
              };
            };
          }
        );
        default = null;
        description = "Minimum resource requirements.";
      };

      ports = mkOption {
        type = types.listOf types.port;
        default = [ ];
        description = "List of container ports to expose.";
      };

      envVars = mkOption {
        type = types.attrsOf (
          types.oneOf (
            with types;
            [
              str
              int
              bool
            ]
          )
        );
        default = { };
        description = "Environment variables passed to the container.";
      };

      volume = mkOption {
        type = types.attrsOf (
          types.submodule {
            options = {
              path = mkOption {
                type = types.str;
                description = "Mount path inside the container.";
              };

              hostPath = mkOption {
                type = types.str;
                description = "Path on the host to mount.";
              };
            };
          }
        );

        default = { };
        description = "Volumes to mount in the container.";
      };

      healthCheck = mkOption {
        type = types.nullOr (
          types.submodule {
            options = {
              tcp.endpoint = mkOption {
                type = types.nullOr types.str;
                default = null;
                description = "TCP health check endpoint (host:port).";
              };
              udp.endpoint = mkOption {
                type = types.nullOr types.str;
                default = null;
                description = "UDP health check endpoint (host:port).";
              };

              http = mkOption {
                type = types.nullOr (
                  types.submodule {
                    options = {
                      endpoint = mkOption {
                        type = types.str;
                        description = "HTTP endpoint URL for health checks.";
                      };

                      method = mkOption {
                        type = types.enum [
                          "GET"
                          "POST"
                          "PUT"
                          "PATCH"
                          "DELETE"
                        ];
                        default = "POST";
                        description = "HTTP method for health checks.";
                      };

                      expectedStatus = mkOption {
                        type = types.int;
                        default = 200;
                        description = "Expected HTTP status code for healthy service.";
                      };
                    };
                  }
                );
                default = null;
                description = "HTTP health check configuration.";
              };
            };
          }
        );
        default = null;
        description = "Health check configuration (tcp, udp, or http).";
      };

      ingress.http = mkOption {
        type = types.attrsOf (
          types.submodule {
            options = {
              host = mkOption {
                type = types.str;
                description = "Hostname for this ingress route.";
              };
              port = mkOption {
                type = types.port;
                description = "Port to expose this route on (80 for HTTP, 443 for HTTPS).";
              };

              path = mkOption {
                type = types.str;
                default = "/";
                description = "URL path prefix for this route.";
              };

              tls = mkOption {
                type = types.bool;
                default = false;
                description = "Enable TLS/HTTPS for this route.";
              };
            };
          }
        );
        default = { };
        description = "HTTP ingress rules for exposing the job.";
      };
    };
  };
in
{
  options.nixmesh.jobs = mkOption {
    type = types.attrsOf job;
    default = { };
    description = "Declarative job definitions for the cluster.";
  };
}
