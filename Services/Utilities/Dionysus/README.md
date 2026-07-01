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

The workloads expect these images:

- `ghcr.io/tobiassaaby/dionysus-api:main`
- `ghcr.io/tobiassaaby/dionysus-web:main`

The Dionysus repository contains a Woodpecker pipeline that builds and pushes
those images once Woodpecker is connected to GitHub and has a
`github_packages_token` secret with package write permissions.
