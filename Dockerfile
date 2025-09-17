FROM mcr.microsoft.com/azure-cli:2.65.0

# Install dependencies
RUN apk update && apk add --no-cache \
    bash \
    jq \
    shadow \
    coreutils \
    curl \
    unzip \
    git \
    && rm -rf /var/cache/apk/*

# Create buildpiper user & group (non-root)
RUN addgroup -g 65522 buildpiper && \
    adduser -D -u 65522 -G buildpiper -h /home/buildpiper buildpiper && \
    mkdir -p /home/buildpiper && chown -R buildpiper:buildpiper /home/buildpiper

# Create required directories & assign permissions
RUN mkdir -p \
    /bp/execution_dir \
    /opt/buildpiper/shell-functions \
    /opt/buildpiper/data \
    /bp/workspace && \
    chown -R buildpiper:buildpiper /src /bp /opt

# Set environment variables
ENV SLEEP_DURATION=5s
ENV ACTIVITY_SUB_TASK_CODE=AZURE_BLOB_UPLOADER

# Copy files with correct ownership
COPY --chown=buildpiper:buildpiper build.sh /home/buildpiper/build.sh
COPY --chown=buildpiper:buildpiper BP-BASE-SHELL-STEPS /opt/buildpiper/shell-functions/

# Set permissions on script and workspace
RUN chmod +x /home/buildpiper/build.sh && \
    chown -R buildpiper:buildpiper /bp/workspace && \
    mkdir -p /home/buildpiper/reports && \
    chown -R buildpiper:buildpiper /home/buildpiper

# Switch to non-root user
USER buildpiper

# Set working directory to user's home
WORKDIR /home/buildpiper

# Entrypoint and default command
ENTRYPOINT ["./build.sh"]
