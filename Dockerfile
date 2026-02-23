FROM ubuntu:25.10

ARG ADSPOWER_VERSION=7.12.29
ARG ADSPOWER_URL=https://version.adspower.net/software/linux-x64-global/${ADSPOWER_VERSION}/AdsPower-Global-${ADSPOWER_VERSION}-x64.deb

# Install system dependencies, LXDE, x11vnc
RUN apt-get update && \
    apt-get install -y \
        # AdsPower dependencies
        libgtk-3-0 \
        libnotify4 \
        libnss3 \
        libxss1 \
        libxtst6 \
        xdg-utils \
        libatspi2.0-0 \
        libsecret-1-0 \
        libasound2t64 \
        # X server and desktop
        xvfb \
        dbus \
        lxde-core \
        lxterminal \
        # VNC
        x11vnc \
        build-essential \
        # Utilities
        wget \
        curl \
        sudo \
        fish

# Download and install AdsPower
ADD ${ADSPOWER_URL} /tmp/adspower.deb

RUN dpkg -i /tmp/adspower.deb || apt-get install -y --fix-broken \
    && rm /tmp/adspower.deb \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user dave
RUN useradd -m -s /bin/bash dave && \
    echo "dave ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir -p /home/dave/.config

# Set up work directory
WORKDIR /app

# Change ownership efficiently
RUN chown -R dave:dave /app /home/dave

# Switch to dave user
USER dave

# Set home directory
ENV HOME=/home/dave

# Copy and setup init script
COPY --chmod=755 init.sh /init.sh

# Expose VNC port and AdsPower API port
EXPOSE 5900 50325

# Run init script
CMD ["/init.sh"]

