#!/bin/bash
set -e

# Install dependencies if node_modules doesn't exist or if package.json has changed
if [ ! -d "node_modules" ] || [ "package.json" -nt "node_modules" ]; then
  echo "Installing dependencies..."
  npm install
fi

# Execute the command passed to the script
echo "Starting application with command: $@"
exec "$@"