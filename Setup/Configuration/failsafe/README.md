# Failsafe Local Credentials

Files in this directory are local-only handoff inputs for the development VPS.

- `kubeconfig` is copied to `/var/lib/hermes/kube/config`.
- `hcloud.env` is copied to `/var/lib/hermes/hcloud.env`.

Both files are ignored by Git. Prefer limited-scope credentials here instead of
full admin tokens.

The Failsafe install also creates `/workspace/ThePaleHeart` on the VPS and
sets it up as a Git checkout owned by the `failsafe` user. Use
`tph-nixos-sync` from that checkout after editing `Setup/NixOS` on the VPS:

```sh
tph-nixos-sync /workspace/ThePaleHeart "Update Failsafe NixOS configuration"
```

That command pulls with fast-forward only, validates the NixOS flake, switches
the host, commits `Setup/NixOS`, and pushes the current branch. The VPS still
needs Git push credentials, for example a deploy key that can write to the
repository.

Run this once after a fresh install to authenticate GitHub and configure Hermes
interactively:

```sh
sudo -u failsafe -H tph-failsafe-auth
```

Choose the ChatGPT/portal login path in the Hermes setup flow if you want to
use an existing ChatGPT subscription instead of API keys. The generated Hermes
auth state lives in `/var/lib/hermes/.hermes` and is reused by the native
`hermes-agent` systemd service.

GitHub is configured through `gh auth login` and HTTPS Git credentials, so no
personal SSH key needs to be copied to the VPS.
