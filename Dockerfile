# Use the official Judge0 base image
FROM judge0/judge0:latest AS production

# Metadata
ENV JUDGE0_HOMEPAGE="https://judge0.com"
LABEL homepage=$JUDGE0_HOMEPAGE

ENV JUDGE0_SOURCE_CODE="https://github.com/judge0/judge0"
LABEL source_code=$JUDGE0_SOURCE_CODE

ENV JUDGE0_MAINTAINER="Herman Zvonimir Došilović <hermanz.dosilovic@gmail.com>"
LABEL maintainer=$JUDGE0_MAINTAINER

# Ensure root permissions for system-level tasks
USER root

# Optional: Add any extra tools you might need
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      sudo && \
    rm -rf /var/lib/apt/lists/*

# Expose the Judge0 API port
EXPOSE 2358

# Set the working directory for the API
WORKDIR /api

# Copy cron jobs (optional)
COPY cron /etc/cron.d
RUN cat /etc/cron.d/* | crontab -

# Environment variables for Judge0 configurations
ENV JUDGE0_TELEMETRY_ENABLE=false \
    ENABLE_WAIT_RESULT=true \
    ENABLE_BATCHED_SUBMISSIONS=false \
    ENABLE_NETWORK=false

# Optional: Ensure proper permissions for Judge0 user
RUN useradd -u 1000 -m -r judge0 && \
    echo "judge0 ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers && \
    chown judge0: /api/tmp/

# Switch to the non-root Judge0 user
USER judge0

# Judge0 version metadata
ENV JUDGE0_VERSION="1.13.1"
LABEL version=$JUDGE0_VERSION

# Define the entry point and command to start the server
ENTRYPOINT ["/api/docker-entrypoint.sh"]
CMD ["/api/scripts/server"]

# Development stage (optional for debugging or extending functionality)
FROM production AS development

# Override CMD for development to keep the container running
CMD ["sleep", "infinity"]
