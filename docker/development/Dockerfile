# Use Ruby 3.3.6 as the base image
FROM ruby:3.3.6-slim

# Install essential Linux packages
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    curl \
    git \
    libpq-dev \
    libjemalloc2 \
    pkg-config \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Configure jemalloc
ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2

# Set working directory
WORKDIR /app

# Install Rails
RUN gem install rails -v 8.0.1

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install dependencies
RUN bundle install

# Copy the rest of the application
COPY . .

# Add a script to be executed every time the container starts
COPY bin/docker-entrypoint /usr/bin/
RUN chmod +x /usr/bin/docker-entrypoint
ENTRYPOINT ["docker-entrypoint"]

# Configure the main process to run when running the image
EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
