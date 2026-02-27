FROM ubuntu:25.10

ARG ADSPOWER_VERSION=7.12.29
ARG ADSPOWER_URL=https://version.adspower.net/software/linux-x64-global/${ADSPOWER_VERSION}/AdsPower-Global-${ADSPOWER_VERSION}-x64.deb

# Space-separated list of additional Chrome kernel versions to pre-install at build time.
# Kernel 142 is already bundled inside the .deb and auto-extracted on first start.
# Add more versions as needed, e.g. "143 134"
ARG EXTRA_KERNELS="143"

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
        fish \
        python3 \
        unzip

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

# Pre-install additional browser kernels.
# Kernel 142 ships inside the .deb and is auto-extracted by AdsPower on first start.
# Each extra kernel (~220 MB) is fetched from AdsPower's CDN via their version API:
#   GET https://api-global.adspower.net/client/browser/get-browser-version
#         ?type=chrome&kernel=<N>&system=linux_x64&is_self_refresh=1
# The response includes a download_url for a zip containing SunBrowser + chromedriver.
RUN if [ -n "${EXTRA_KERNELS}" ]; then \
        mkdir -p /home/dave/.config/adspower_global/cwd_global; \
        for kernel in ${EXTRA_KERNELS}; do \
            echo "==> Downloading SunBrowser kernel ${kernel}..." && \
            KERNEL_URL=$(curl -sf \
                "https://api-global.adspower.net/client/browser/get-browser-version?type=chrome&kernel=${kernel}&system=linux_x64&is_self_refresh=1" \
                | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['download_url'])") && \
            echo "    URL: ${KERNEL_URL}" && \
            curl -L "${KERNEL_URL}" -o /tmp/chrome_${kernel}.zip && \
            KERNEL_DIR=/home/dave/.config/adspower_global/cwd_global/chrome_${kernel} && \
            mkdir -p ${KERNEL_DIR} && \
            unzip -q /tmp/chrome_${kernel}.zip -d ${KERNEL_DIR}/ && \
            if [ ! -f "${KERNEL_DIR}/SunBrowser" ]; then \
                SUBDIR=$(ls -1 ${KERNEL_DIR}/ | head -1) && \
                mv ${KERNEL_DIR}/${SUBDIR}/* ${KERNEL_DIR}/ && \
                rmdir ${KERNEL_DIR}/${SUBDIR}; \
            fi && \
            chmod +x ${KERNEL_DIR}/SunBrowser && \
            rm /tmp/chrome_${kernel}.zip && \
            echo "    Kernel ${kernel} installed."; \
        done && \
        chown -R dave:dave /home/dave/.config; \
    fi

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

