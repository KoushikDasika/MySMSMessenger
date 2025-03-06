#!/bin/bash

# Essential Rails Docker Compose Helper Functions

function base_run() {
  docker compose run --rm --entrypoint '' -it "$@"
}

# Run Rails server
function rails() {
  base_run api rails s -b 0.0.0.0
}

# Run Rails console
function console() {
  base_run api rails c
}

# Run database migrations
function migrate() {
  base_run api rails db:migrate
}

# Run tests
function rspec() {
  base_run api bundle exec rspec "$@"
}

# Run any command in the api container
function run() {
  base_run api "$@"
}

# Run any command in the frontend container
function run-frontend() {
  base_run frontend "$@"
}

# Run any command in the frontend container
function run-frontend() {
  base_run frontend "$@"
}

# Open a bash shell in the api container
function bash() {
  base_run api bash
}

# Open a bash shell in the frontend container
function bash-frontend() {
  base_run frontend bash
}

function restart() {
  docker compose restart "$@"
}

# Build the Docker image
function build() {
  docker compose build \
         -f api/docker/production/Dockerfile \
         -t my-sms-messenger-api:latest
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
