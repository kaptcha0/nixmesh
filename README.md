## NixMesh

A Nix-native alternative to Kubernetes for people who don't want to leave the NixOS ecosystem. Describe your entire cluster in one `flake.nix` — nodes, jobs, storage, secrets, ingress — and NixMesh handles placement, routing, and updates.

**Features**
- Declarative job scheduling with hardware constraints and node pinning
- Automatic Traefik ingress config, hot-reloaded as jobs move
- GitOps-native updates via comin — workers pull changes without the master pushing to them
- Secrets stay encrypted in the repo, decrypted only on the node that needs them (sops-nix)
- Master failover with no state sync — full cluster state lives in Consul
- Works on a single machine with no configuration change

**What it's built on**

Colmena, comin, Consul, Traefik, and sops-nix. No custom replication, no custom secret management, no custom health checking — just NixOS modules composing tools that already do their jobs well.

**Status**

Early development and not ready for production. The module schema is designed and the library structure is in place, but the scheduler and deployment pipeline are still being built. Contributions and feedback welcome.