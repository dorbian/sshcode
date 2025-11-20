# Code TUI SSH Container (Podman + ConfigMap SSH keys + zsh)

This directory contains:

- An Ubuntu-based image with:
  - OpenSSH server
  - tmux
  - Neovim
  - zsh (as the default shell for user **dev**)
- A TUI layout that feels a bit like VSCode:
  - SSH user **dev** is dropped directly into a tmux session with Neovim + shell.
- A Kubernetes-style YAML that works with **podman kube play**, including:
  - A ConfigMap that holds SSH public keys.
  - A Pod that mounts that ConfigMap into the container at `/ssh-keys`, which are then imported into `/home/dev/.ssh/authorized_keys` on startup.

## Files

- `Dockerfile` — builds the image `code-tui-ssh-podman-zsh`.
- `.tmux.conf` — tmux configuration (VSCode-ish UI).
- `init.vim` — minimal Neovim configuration.
- `tmux-session.sh` — creates/attaches to the `code` tmux session with the TUI layout.
- `zshrc` — zsh configuration for user `dev`:
  - Simple prompt
  - Auto-attaches to the tmux `code` session for interactive logins.
- `import-ssh-keys.sh` — runs at container start, imports keys from `/ssh-keys` into `/home/dev/.ssh/authorized_keys`, then starts `sshd`.
- `authorized_keys` — placeholder, left empty; can be used at build time if desired.
- `podman-kube.yaml` — example ConfigMap + Pod definition for `podman kube play`.

## Build the image

From this directory:

```bash
podman build -t code-tui-ssh-podman-zsh .
```

(or `docker build` if you're using Docker; the image is OCI-compatible.)

## Using with podman kube play

1. Adjust the hostPath in `podman-kube.yaml`:

```yaml
      hostPath:
        path: /srv/code-tui-work   # change this to your desired host directory
```

2. Edit the ConfigMap part in `podman-kube.yaml` to include your real SSH public keys:

```yaml
data:
  id_ed25519.pub: |
    ssh-ed25519 AAAA...your-real-key... you@host
```

You can add multiple keys as extra entries.

3. Run with:

```bash
podman kube play podman-kube.yaml
```

This will:

- Create the ConfigMap `code-tui-ssh-keys`.
- Start the Pod `code-tui` using the `code-tui-ssh-podman-zsh:latest` image (built earlier).

## SSH access

The container exposes port 22. With `podman kube play`, you can:

- Either rely on host networking, or
- Use additional `podman` / CNI / firewall rules to expose the port externally.

By default, the image:

- Only allows the user `dev`.
- Disables password authentication.
- Uses `~dev/.ssh/authorized_keys` (populated from `/ssh-keys`) for key-based logins.
- Uses **zsh** as the default shell for `dev`.

Once connected via SSH as `dev`, you'll automatically land in:

- tmux session `code`
- left pane: Neovim in `/work`
- right pane: shell in `/work`
