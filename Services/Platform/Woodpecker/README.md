# Woodpecker CI

Argo CD deploys Woodpecker from the upstream Helm chart.

## Runtime secrets

Do **not** commit these values. Create them in the cluster before syncing the
Application:

```sh
kubectl -n woodpecker create secret generic woodpecker-agent-secret \
  --from-literal=WOODPECKER_AGENT_SECRET="$(openssl rand -hex 32)"

kubectl -n woodpecker create secret generic woodpecker-github-oauth \
  --from-literal=WOODPECKER_GITHUB_CLIENT="<github-oauth-client-id>" \
  --from-literal=WOODPECKER_GITHUB_SECRET="<github-oauth-client-secret>"
```

GitHub OAuth app callback URL:

```text
https://woodpecker.saaby.no/authorize
```

The chart is configured to use Kubernetes agents in the `woodpecker` namespace
with Longhorn-backed work volumes.
