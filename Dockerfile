# Use the pre-built judge0 image from Docker Hub as the base
FROM judge0/judge0:latest AS production

# Metadata
ENV JUDGE0_HOMEPAGE "https://judge0.com"
LABEL homepage=$JUDGE0_HOMEPAGE

ENV JUDGE0_SOURCE_CODE "https://github.com/judge0/judge0"
LABEL source_code=$JUDGE0_SOURCE_CODE

ENV JUDGE0_MAINTAINER "Herman Zvonimir Došilović <hermanz.dosilovic@gmail.com>"
LABEL maintainer=$JUDGE0_MAINTAINER

# Optional: Add extra tools if needed
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      sudo && \
    rm -rf /var/lib/apt/lists/*

# Expose the API port
EXPOSE 2358

# Work directory for the API
WORKDIR /api

# Copy necessary files (e.g., configuration or scripts) into the container
COPY cron /etc/cron.d
RUN cat /etc/cron.d/* | crontab -

# Configure default settings via environment variables (override as needed)
ENV JUDGE0_TELEMETRY_ENABLE=false
ENV ENABLE_WAIT_RESULT=true
ENV ENABLE_BATCHED_SUBMISSIONS=false
ENV REDIS_HOST=""
ENV POSTGRES_HOST=""
ENV ENABLE_NETWORK=false

# Optional: Ensure proper permissions
RUN useradd -u 1000 -m -r judge0 && \
    echo "judge0 ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers && \
    chown judge0: /api/tmp/

# Switch to judge0 user for running the application
USER judge0

# Version metadata
ENV JUDGE0_VERSION "1.13.1"
LABEL version=$JUDGE0_VERSION

# Entry point and command to start the server
ENTRYPOINT ["/api/docker-entrypoint.sh"]
CMD ["/api/scripts/server"]

# Development stage (optional, for debugging or extending functionality)
FROM production AS development

# Override CMD for development
CMD ["sleep", "infinity"]
