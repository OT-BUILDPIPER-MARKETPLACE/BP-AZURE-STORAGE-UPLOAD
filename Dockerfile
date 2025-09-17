FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies + prerequisites for Azure CLI
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    jq \
    git \
    unzip \
    bash \
    coreutils \
    passwd \
    && rm -rf /var/lib/apt/lists/*

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash


# Create buildpiper user & group
RUN groupadd -g 65522 buildpiper && \
    useradd -m -u 65522 -g buildpiper -s /bin/bash buildpiper && \
    mkdir -p /home/buildpiper && chown -R buildpiper:buildpiper /home/buildpiper

# Create required directories & assign permissions
RUN mkdir -p \
    /bp/execution_dir \
    /opt/buildpiper/shell-functions \
    /opt/buildpiper/data \
    /bp/workspace && \
    chown -R buildpiper:buildpiper /src /bp /opt || true

# Set environment variables
ENV SLEEP_DURATION=5s
ENV ACTIVITY_SUB_TASK_CODE=AZURE_BLOB_UPLOADER

# Copy scripts
COPY --chown=buildpiper:buildpiper build.sh /home/buildpiper/build.sh
COPY --chown=buildpiper:buildpiper BP-BASE-SHELL-STEPS /opt/buildpiper/shell-functions/

# Set permissions
RUN chmod +x /home/buildpiper/build.sh && \
    chown -R buildpiper:buildpiper /bp/workspace && \
    mkdir -p /home/buildpiper/reports && \
    chown -R buildpiper:buildpiper /home/buildpiper

# Switch to non-root
USER buildpiper

WORKDIR /home/buildpiper

ENTRYPOINT ["./build.sh"]