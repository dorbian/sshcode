FROM ubuntu:24.04

# Basic CLI tooling + OpenSSH + zsh
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        neovim tmux git curl ripgrep fd-find \
        openssh-server zsh \
        locales ca-certificates && \
    ln -s /usr/bin/fdfind /usr/local/bin/fd && \
    locale-gen en_US.UTF-8 && \
    rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Prepare SSH daemon
RUN mkdir -p /var/run/sshd

# Non-root user with zsh as default shell
RUN useradd -ms /usr/bin/zsh dev

# SSH directory and nvim config for dev user
RUN mkdir -p /home/dev/.ssh /home/dev/.config/nvim && \
    chown -R dev:dev /home/dev && \
    chmod 700 /home/dev/.ssh

# Harden sshd: key-only, no root login
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config && \
    echo 'AllowUsers dev' >> /etc/ssh/sshd_config

# Copy configs
COPY .tmux.conf /home/dev/.tmux.conf
COPY init.vim /home/dev/.config/nvim/init.vim
COPY tmux-session.sh /home/dev/tmux-session.sh
COPY zshrc /home/dev/.zshrc
COPY import-ssh-keys.sh /usr/local/bin/import-ssh-keys.sh
COPY authorized_keys /home/dev/.ssh/authorized_keys

RUN chown -R dev:dev /home/dev && \
    chmod 600 /home/dev/.ssh/authorized_keys && \
    chmod +x /home/dev/tmux-session.sh /usr/local/bin/import-ssh-keys.sh

WORKDIR /home/dev

# Expose SSH
EXPOSE 22

# Default entrypoint: import mounted SSH keys then run sshd in foreground
ENTRYPOINT ["/usr/sbin/sshd", "-D", "-e"]
