#!/bin/bash
set -e

echo "Installing dependencies..."
npm install

# Execute the command passed to the script
echo "Starting application with command: $@"
exec "$@"