# Dionysus

Dionysus is deployed by Argo CD from this kustomize directory. Application
source code lives in [`TobiasSaaby/Dionysus`](https://github.com/TobiasSaaby/Dionysus).

## Runtime secret

Do **not** commit the real database password. Create it in the cluster before
syncing the Application:

```sh
kubectl create namespace dionysus
DIONYSUS_DB_PASSWORD="$(openssl rand -hex 24)"
kubectl -n dionysus create secret generic dionysus-db \
  --from-literal=POSTGRES_DB=dionysus \
  --from-literal=POSTGRES_USER=dionysus \
  --from-literal=POSTGRES_PASSWORD="$DIONYSUS_DB_PASSWORD" \
  --from-literal=DATABASE_URL="postgresql+psycopg://dionysus:${DIONYSUS_DB_PASSWORD}@dionysus-postgres:5432/dionysus"
```

## Images

The workloads are updated through the Dionysus Woodpecker GitOps pipeline.
Woodpecker builds immutable Docker Hub tags from the Dionysus commit SHA, then
commits those tags back to these manifests. Argo CD deploys from that Git change.

Current image fields are intentionally managed by CI:

- `Services/Utilities/Dionysus/api.deployment.yaml`
- `Services/Utilities/Dionysus/web.deployment.yaml`

The Dionysus repository contains a Woodpecker pipeline that builds and pushes
images to Docker Hub once Woodpecker is connected to GitHub and has these
repository secrets:

- `dockerhub_username`
- `dockerhub_token`
- `gitops_github_token` — GitHub token with permission to push to
  `TobiasSaaby/ThePaleHeart`
