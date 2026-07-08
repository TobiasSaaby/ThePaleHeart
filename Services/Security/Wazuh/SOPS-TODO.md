# Wazuh SOPS migration TODO

Current implementation uses an ignored local `.env` file plus generated local certificate files. This is intentionally simple and keeps raw secrets out of Git.

## Later SOPS migration

- [ ] Add an age key for the cluster/operator and document where the private key is stored.
- [ ] Add `.sops.yaml` with creation rules for Kubernetes secret manifests under `Services/Security/Wazuh`.
- [ ] Convert `secrets.env` values into encrypted SOPS-managed Kubernetes `Secret` manifests.
- [ ] Decide how to handle internal Wazuh certificate material:
  - [ ] encrypt generated cert/key files directly, or
  - [ ] encrypt seed values and regenerate certs during bootstrap.
- [ ] Add Argo CD SOPS decryption support, or deploy a controller such as External Secrets/KSOPS if preferred.
- [ ] Remove the manual `.env` apply step after encrypted GitOps secrets are verified.
- [ ] Document rotation procedure for Wazuh authd password, cluster key, indexer/dashboard credentials, and cert bundles.

## Acceptance criteria

- [ ] A fresh cluster sync can create all Wazuh runtime secrets without raw secret files outside Git except the SOPS private key.
- [ ] Raw secrets are never committed.
- [ ] Wazuh reaches `Synced/Healthy` after deleting and recreating the `wazuh` namespace.
