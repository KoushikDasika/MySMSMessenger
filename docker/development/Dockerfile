# Use Ruby 3.4.2 as the base image
FROM ruby:3.4.2

# Install essential Linux packages
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    curl \
    git \
    libjemalloc2 \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Configure jemalloc
ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2

# Set working directory
WORKDIR /app

# Install Rails
RUN gem install rails -v 8.0.1

# Copy Gemfile and Gemfile.lock
COPY api/Gemfile api/Gemfile.lock ./

# Install dependencies
RUN bundle install

# Copy the rest of the application
COPY api/ .

# Add a script to be executed every time the container starts
COPY api/bin/docker-entrypoint /usr/bin/
RUN chmod +x /usr/bin/docker-entrypoint

EXPOSE 3000

ENTRYPOINT ["docker-entrypoint"]