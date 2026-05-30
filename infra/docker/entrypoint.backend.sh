#!/usr/bin/env bash
set -e

# Wait for Postgres to accept connections.
echo "Waiting for database at ${POSTGRES_HOST:-db}:${POSTGRES_PORT:-5432}..."
until python -c "import socket,os,sys; s=socket.socket(); s.settimeout(2); \
    s.connect((os.environ.get('POSTGRES_HOST','db'), int(os.environ.get('POSTGRES_PORT','5432')))) \
    or sys.exit(0)" 2>/dev/null; do
  sleep 1
done

python manage.py migrate --noinput
exec "$@"
