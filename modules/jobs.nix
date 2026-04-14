{ lib, ... }:
let
  inherit (lib) mkOption types;

  image = types.submodule {
    options.image = mkOption {
      type = types.str;
    };
  };

  native = types.submodule {
    options.config = mkOption {
      type = types.deferredModule;
    };
  };

  job = types.submodule {
    options = {
      container = mkOption {
        type = types.oneOf [
          image
          native
        ];
      };

      prefersNode = mkOption {
        type = types.nullOr types.str;
        default = null;
      };

      requires = mkOption {
        type = types.nullOr (
          types.submodule {
            options = {
              memory = mkOption { type = types.int; };
              cpuCores = mkOption { type = types.int; };
            };
          }
        );
        default = null;
      };

      ports = mkOption {
        type = types.listOf types.port;
        default = [ ];
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
      };

      volume = mkOption {
        type = types.attrsOf (
          types.submodule {
            options = {
              path = mkOption {
                type = types.str;
              };

              hostPath = mkOption {
                type = types.str;
              };
            };
          }
        );

        default = { };
      };

      healthCheck = mkOption {
        type = types.nullOr (
          types.submodule {
            options = {
              tcp.endpoint = mkOption {
                type = types.nullOr types.str;
                default = null;
              };
              udp.endpoint = mkOption {
                type = types.nullOr types.str;
                default = null;
              };

              http = mkOption {
                type = types.nullOr (
                  types.submodule {
                    options = {
                      endpoint = mkOption { type = types.str; };

                      method = mkOption {
                        type = types.enum [
                          "GET"
                          "POST"
                          "PUT"
                          "PATCH"
                          "DELETE"
                        ];
                        default = "POST";
                      };

                      expectedStatus = mkOption {
                        type = types.int;
                        default = 200;
                      };
                    };
                  }
                );
                default = null;
              };
            };
          }
        );
        default = null;
      };

      ingress.http = mkOption {
        type = types.attrsOf (
          types.submodule {
            options = {
              host = mkOption { type = types.str; };
              port = mkOption { type = types.port; };
              path = mkOption { type = types.str; };

              tls = {
                type = types.bool;
                default = false;
              };
            };
          }
        );
        default = { };
      };
    };
  };
in
{
  options.nixmesh.cluster.jobs = mkOption {
    type = types.attrsOf job;
    default = { };
  };
}
