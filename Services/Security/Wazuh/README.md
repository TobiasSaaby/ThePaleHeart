# Wazuh secret handling

Wazuh needs runtime credentials and internal TLS material that must not be committed to Git.

## Current approach: ignored local files

1. Copy `secrets.env.example` to `secrets.env`.
2. Fill real values and keep permissions tight: `chmod 600 secrets.env`.
3. Run `scripts/apply-secrets.sh` from the repository root.

The script creates/applies these Kubernetes secrets in the `wazuh` namespace:

- `wazuh-authd-pass`
- `wazuh-cluster-key`
- `indexer-cred`
- `dashboard-cred`
- `wazuh-api-cred`
- `indexer-certs`
- `dashboard-certs`

The real `.env` and generated certificate files are ignored by Git.

## SOPS migration TODO

- [ ] Add an age key for Failsafe/Argo secret decryption.
- [ ] Add `.sops.yaml` with path rules for `Services/**/secrets*.yaml`.
- [ ] Convert Wazuh secrets to encrypted SOPS manifests.
- [ ] Add Argo CD SOPS integration or a decrypt/apply bootstrap step.
- [ ] Document key backup/rotation.
- [ ] Remove dependence on local unencrypted `secrets.env` once SOPS is working.
