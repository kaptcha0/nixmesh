# nixmesh
## overview
**nixmesh** is a Nix-native cluster orchestration system that manages an entire fleet of machines as a single NixOS configuration. Instead of bolting Kubernetes onto Linux, nixmesh builds on primitives already in NixOS — systemd, WireGuard, microVMs, and atomic generations — to deliver high-availability workload scheduling at a fraction of the complexity and overhead.

Jobs, placement rules, storage, and networking are all declared in one flake. No YAML, no etcd, no Helm — just Nix. A static scheduler resolves workload placement at build time, while a lightweight daemon handles runtime rebalancing across node failures and resource shifts. Rollbacks are atomic, secrets use `agenix` or `sops-nix`, and GitOps is a systemd unit rather than a separate platform.
han a separate platform.
