# Longhorn storage policy

Longhorn is used for replicated in-cluster block storage, not as a substitute for
application-level high availability or off-cluster backups.

## Cluster defaults

- `local-path` remains the default StorageClass for accidental/unspecified PVCs.
- Workloads must explicitly opt in to Longhorn with `storageClassName: longhorn`.
- Longhorn volumes default to 3 replicas and strict anti-affinity across nodes/disks.
- Over-provisioning is disabled (`100%`) and reserve/minimum free capacity is kept so
  rebuilds have room to complete.

## Workload placement

Use Longhorn for small, important state:

- CI server metadata
- small application databases
- security/observability control-plane state

Avoid Longhorn for disposable or high-churn data when possible:

- build caches
- temporary workspaces
- regenerated logs/metrics
- media/transcode scratch space

For databases that must survive node/storage incidents with minimal downtime, prefer
application-native replication or an external managed database over a single-writer
PVC alone.

## External storage recommendation

External storage is worth considering for this homelab, but by workload type:

- **Object storage/S3-compatible backup target**: strongly recommended for Longhorn
  recurring backups and database dumps. This gives off-cluster recovery when Longhorn
  itself is unhealthy.
- **Managed Postgres**: recommended for critical app databases if uptime matters more
  than self-hosting purity.
- **NFS/SMB NAS**: useful for shared media and bulk files, but not a fix for database
  HA and often weaker than Longhorn for small synchronous writes.
- **Ceph/Rook**: viable only if the cluster grows and we accept more operational
  complexity; not a free stability upgrade on three small nodes.
