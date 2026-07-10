#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
WAZUH_DIR="$ROOT/Services/Security/Wazuh"
ENV_FILE="${WAZUH_SECRET_ENV:-$WAZUH_DIR/secrets.env}"
CERT_DIR="$WAZUH_DIR/certs/indexer_cluster"
NS="${WAZUH_NAMESPACE:-wazuh}"

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl is required" >&2
  exit 1
fi
if ! command -v openssl >/dev/null 2>&1; then
  echo "openssl is required. On Failsafe: nix shell nixpkgs#openssl -c $0" >&2
  exit 1
fi

random_secret() {
  openssl rand -base64 32 | tr -d '\n'
}

random_cluster_key() {
  # Wazuh cluster keys must be 32 alphanumeric characters. Base64 output can
  # contain symbols that make wazuh-clusterd reject the configuration.
  openssl rand -base64 48 | tr -dc 'A-Za-z0-9' | head -c 32
}

if [ ! -f "$ENV_FILE" ]; then
  umask 077
  cat >"$ENV_FILE" <<EOF
WAZUH_AUTHD_PASS=$(random_secret)
WAZUH_CLUSTER_KEY=$(random_cluster_key)
INDEXER_USERNAME=admin
INDEXER_PASSWORD=$(random_secret)
DASHBOARD_USERNAME=kibanaserver
DASHBOARD_PASSWORD=$(random_secret)
WAZUH_API_USERNAME=wazuh
WAZUH_API_PASSWORD=$(random_secret)
EOF
  echo "Created $ENV_FILE"
fi

set -a
# shellcheck disable=SC1090
. "$ENV_FILE"
set +a

required=(
  WAZUH_AUTHD_PASS WAZUH_CLUSTER_KEY
  INDEXER_USERNAME INDEXER_PASSWORD
  DASHBOARD_USERNAME DASHBOARD_PASSWORD
  WAZUH_API_USERNAME WAZUH_API_PASSWORD
)
for key in "${required[@]}"; do
  if [ -z "${!key:-}" ] || [[ "${!key}" == replace-* ]]; then
    echo "$key is missing or still a placeholder in $ENV_FILE" >&2
    exit 1
  fi
done

kubectl get namespace "$NS" >/dev/null 2>&1 || kubectl create namespace "$NS"

if [ ! -f "$CERT_DIR/root-ca.pem" ] || [ ! -f "$CERT_DIR/node.pem" ] || [ ! -f "$CERT_DIR/filebeat.pem" ] || [ ! -f "$CERT_DIR/dashboard.pem" ]; then
  (cd "$CERT_DIR" && bash ./generate_certs.sh)
fi

kubectl -n "$NS" create secret generic wazuh-authd-pass \
  --from-literal=authd.pass="$WAZUH_AUTHD_PASS" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl -n "$NS" create secret generic wazuh-cluster-key \
  --from-literal=key="$WAZUH_CLUSTER_KEY" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl -n "$NS" create secret generic indexer-cred \
  --from-literal=username="$INDEXER_USERNAME" \
  --from-literal=password="$INDEXER_PASSWORD" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl -n "$NS" create secret generic dashboard-cred \
  --from-literal=username="$DASHBOARD_USERNAME" \
  --from-literal=password="$DASHBOARD_PASSWORD" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl -n "$NS" create secret generic wazuh-api-cred \
  --from-literal=username="$WAZUH_API_USERNAME" \
  --from-literal=password="$WAZUH_API_PASSWORD" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl -n "$NS" create secret generic indexer-certs \
  --from-file=root-ca.pem="$CERT_DIR/root-ca.pem" \
  --from-file=node.pem="$CERT_DIR/node.pem" \
  --from-file=node-key.pem="$CERT_DIR/node-key.pem" \
  --from-file=admin.pem="$CERT_DIR/admin.pem" \
  --from-file=admin-key.pem="$CERT_DIR/admin-key.pem" \
  --from-file=filebeat.pem="$CERT_DIR/filebeat.pem" \
  --from-file=filebeat-key.pem="$CERT_DIR/filebeat-key.pem" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl -n "$NS" create secret generic dashboard-certs \
  --from-file=root-ca.pem="$CERT_DIR/root-ca.pem" \
  --from-file=cert.pem="$CERT_DIR/dashboard.pem" \
  --from-file=key.pem="$CERT_DIR/dashboard-key.pem" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Wazuh runtime secrets applied to namespace $NS"
