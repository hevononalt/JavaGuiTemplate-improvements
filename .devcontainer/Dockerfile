FROM mcr.microsoft.com/devcontainers/java:1-21-bookworm

# Fix for expired Yarn GPG key
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor > /usr/share/keyrings/yarn-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/yarn-archive-keyring.gpg] https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list

# Install minimal dependencies for noVNC (lighter than before)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        x11vnc \
        xvfb \
        fluxbox \
        supervisor \
        python3 \
        python3-numpy \
        net-tools && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install noVNC + websockify (pinned versions for stability)
RUN git clone --depth 1 --branch v1.4.0 https://github.com/novnc/noVNC.git /opt/novnc && \
    git clone --depth 1 --branch v0.11.0 https://github.com/novnc/websockify.git /opt/novnc/utils/websockify && \
    ln -s /opt/novnc/vnc.html /opt/novnc/index.html && \
    rm -rf /opt/novnc/.git /opt/novnc/utils/websockify/.git

# Create directories with proper permissions
RUN mkdir -p /etc/supervisor/conf.d /var/supervisor /var/libs && \
    chown -R vscode /var/supervisor /var/libs

# Copy configurations
COPY supervisord-novnc.conf /etc/supervisor/conf.d/supervisord-novnc.conf
COPY stdlib.jar /var/libs/stdlib.jar

# Set environment variables for display
RUN echo "export DISPLAY=:0" >> /home/vscode/.bashrc && \
    echo "export CLASSPATH=/var/libs/stdlib.jar:." >> /home/vscode/.bashrc

# Expose noVNC port
EXPOSE 6080

# Health check
HEALTHCHECK --interval=10s --timeout=5s --retries=3 \
    CMD ss -ltn | grep -q ':6080' || exit 1
