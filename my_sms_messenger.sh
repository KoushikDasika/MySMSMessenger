#!/bin/bash

# Essential Rails Docker Compose Helper Functions

# Run Rails server
function rails() {
  docker compose run --rm --service-ports api rails s -b 0.0.0.0
}

# Run Rails console
function console() {
  docker compose run --rm api rails c
}

# Run database migrations
function migrate() {
  docker compose run --rm api rails db:migrate
}

# Run tests
function rspec() {
  docker compose run --rm api bundle exec rspec "$@"
}

# Run any command in the api container
function run() {
  docker compose run --rm -it api "$@"
}

# Open a bash shell in the api container
function bash() {
  docker compose exec api bash
}

# Open a bash shell in the frontend container
function bash-frontend() {
  docker compose exec frontend bash
}

# Build the Docker image
function build() {
  docker compose build
}

# Handle command line arguments
if [ $# -gt 0 ]; then
  # Check if the first argument is a defined function
  if declare -f "$1" > /dev/null; then
    # Call the function with all arguments passed to it
    "$@"
  else
    echo "Function '$1' not defined in this script"
    exit 1
  fi
fi
