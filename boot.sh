#!/bin/bash

# Exit immediately if a command fails
set -e

# Wait for MySQL
echo "Waiting for MySQL..."
while ! nc -z db 3306; do
  sleep 1
done
echo "MySQL is up!"

# Wait for Elasticsearch
echo "Waiting for Elasticsearch..."
while ! nc -z elasticsearch 9200; do
  sleep 1
done
echo "Elasticsearch is up"

# Run database migrations with retry loop
while true; do
    flask db upgrade
    if [[ "$?" == "0" ]]; then
        break
    fi
    echo "Database upgrade failed, retrying in 5 secs..."
    sleep 5
done

# Compile translations (optional, safe to skip if not used)
flask translate compile || echo "No translations found, skipping"

# Start Flask with Gunicorn
exec gunicorn -b 0.0.0.0:5000 --access-logfile - --error-logfile - microblog:app
