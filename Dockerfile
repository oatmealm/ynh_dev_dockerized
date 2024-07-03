# Use Debian 11 (Bullseye) as the base image
FROM debian:bullseye

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install systemd and other necessary packages
RUN set -xe \
    # avoid relinking /etc/resolv.conf
    && echo "resolvconf resolvconf/linkify-resolvconf boolean false" | debconf-set-selections \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates \
       curl \
       systemd \
       systemd-sysv \
       iputils-ping \
       apt-utils \
    && rm -rf /var/lib/apt/lists/*

# Add Tailscale repository
RUN curl -fsSL https://pkgs.tailscale.com/stable/debian/bullseye.noarmor.gpg | tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null && \
    curl -fsSL https://pkgs.tailscale.com/stable/debian/bullseye.tailscale-keyring.list | tee /etc/apt/sources.list.d/tailscale.list

# Install Tailscale
RUN apt-get update && apt-get install -y tailscale

# Remove unnecessary services
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;\
    rm -f /lib/systemd/system/anaconda.target.wants/*;

# Enable bash completion
RUN echo "source /etc/bash_completion" >> /etc/bash.bashrc

# Create a script to install Yunohost
RUN echo '#!/bin/bash' > /install_yunohost.sh && \
    echo 'curl https://install.yunohost.org | bash -s -- -a' >> /install_yunohost.sh && \
    chmod +x /install_yunohost.sh

# Run YunoHost installation script at build time [needs systemd, won't work]
# RUN /install_yunohost.sh -a -f

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Expose ports 80 and 443
EXPOSE 80 443

# Set the command to start and wait
CMD ["/lib/systemd/systemd"]
