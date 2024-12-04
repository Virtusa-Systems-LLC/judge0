# Use the official Judge0 base image
FROM judge0/judge0:latest AS production

# Metadata
ENV JUDGE0_HOMEPAGE="https://judge0.com"
LABEL homepage=$JUDGE0_HOMEPAGE

ENV JUDGE0_SOURCE_CODE="https://github.com/judge0/judge0"
LABEL source_code=$JUDGE0_SOURCE_CODE

ENV JUDGE0_MAINTAINER="Herman Zvonimir Došilović <hermanz.dosilovic@gmail.com>"
LABEL maintainer=$JUDGE0_MAINTAINER

# Fix permissions and update the environment
USER root

# Set non-interactive mode for apt
ENV DEBIAN_FRONTEND=noninteractive

# Update package lists and install additional dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      cron \
      libpq-dev \
      sudo && \
    rm -rf /var/lib/apt/lists/*

# Set Ruby environment and install dependencies
ENV PATH="/usr/local/ruby-2.7.0/bin:/opt/.gem/bin:$PATH"
ENV GEM_HOME="/opt/.gem/"
RUN echo "gem: --no-document" > /root/.gemrc && \
    gem install bundler:2.1.4

# Install Node.js dependencies globally
RUN npm install -g --unsafe-perm aglio@2.3.0

# Expose the Judge0 API port
EXPOSE 2358

# Set the working directory for the API
WORKDIR /api

# Copy Gemfile and install Ruby gems
COPY Gemfile* ./
RUN RAILS_ENV=production bundle install

# Copy cron jobs and configure crontab
COPY cron /etc/cron.d
RUN chmod 0644 /etc/cron.d/* && crontab /etc/cron.d/*

# Copy the application code into the image
COPY . .

# Ensure proper permissions for Judge0 user
RUN useradd -u 1000 -m -r judge0 && \
    echo "judge0 ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers && \
    chown -R judge0:judge0 /api

# Switch to the non-root Judge0 user
USER judge0

# Judge0 version metadata
ENV JUDGE0_VERSION="1.13.1"
LABEL version=$JUDGE0_VERSION

# Define the entry point and default command
ENTRYPOINT ["/api/docker-entrypoint.sh"]
CMD ["/api/scripts/server"]

# Development stage for debugging
FROM production AS development

# Keep the container running for development purposes
CMD ["sleep", "infinity"]
