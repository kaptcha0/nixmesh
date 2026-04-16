{
  nodeName,
  nixmesh,
  lib,
  ...
}:
let
  jobs = nixmesh.cluster.jobs;
  ociConfigs = lib.filterAttrs (
    jobName: jobConfig: (builtins.typeOf jobConfig.container) == "string"
  ) jobs;
  nativeConfigs = lib.filterAttrs (
    jobName: jobConfig:
    let
      type = builtins.typeOf jobConfig.container;
    in
    (type == "set") || (type == "lambda")
  ) jobs;
in
{ }
