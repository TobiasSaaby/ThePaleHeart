# Failsafe Local Credentials

Files in this directory are local-only handoff inputs for the development VPS.

- `kubeconfig` is copied to `/root/.kube/config`.
- `hcloud.env` is copied to `/root/.config/the-pale-heart/hcloud.env`.

Both files are ignored by Git. Prefer limited-scope credentials here instead of
full admin tokens.
