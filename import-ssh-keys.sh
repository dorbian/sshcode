#!/usr/bin/env bash
set -e

SSH_DIR="/home/dev/.ssh"
AUTH_KEYS="$SSH_DIR/authorized_keys"
SRC_DIR="/ssh-keys"

# Ensure .ssh and authorized_keys exist with correct permissions
mkdir -p "$SSH_DIR"
touch "$AUTH_KEYS"
chown dev:dev "$SSH_DIR" "$AUTH_KEYS"
chmod 700 "$SSH_DIR"
chmod 600 "$AUTH_KEYS"

# If a volume with SSH keys is mounted at /ssh-keys, import them
if [ -d "$SRC_DIR" ]; then
  # Clear existing keys to reflect current mounted set
  : > "$AUTH_KEYS"
  for f in "$SRC_DIR"/*; do
    [ -f "$f" ] || continue
    cat "$f" >> "$AUTH_KEYS"
    echo >> "$AUTH_KEYS"
  done
  chown dev:dev "$AUTH_KEYS"
  chmod 600 "$AUTH_KEYS"
fi

# Finally, run sshd in the foreground
exec /usr/sbin/sshd -D -e
