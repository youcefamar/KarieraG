#!/usr/bin/env bash
# run.sh — fast local dev launcher for Kariera
# Usage:
#   ./run.sh          → start full stack (docker infra + backend + mobile)
#   ./run.sh backend  → backend only (assumes docker infra already up)
#   ./run.sh mobile   → mobile only
#   ./run.sh infra    → docker infra only (db + redis)
#   ./run.sh stop     → stop docker infra
#   ./run.sh logs     → tail backend logs
#   ./run.sh shell    → Django shell
#   ./run.sh test     → run backend tests

set -e

COMPOSE="docker compose -f infra/docker/docker-compose.local.yml"

start_infra() {
  echo "▶ Starting infra (db + redis)..."
  $COMPOSE up -d db redis
  echo "⏳ Waiting for postgres..."
  until $COMPOSE exec -T db pg_isready -U kariera &>/dev/null; do sleep 1; done
  echo "✅ Infra ready"
}
start_backend() {
  echo "▶ Starting Django backend..."
  cd backend
  python manage.py migrate --run-syncdb 2>/dev/null || true
  python manage.py runserver 0.0.0.0:8000
}

start_mobile() {
  echo "▶ Starting Expo mobile..."
  cd mobile
  npx expo start
}

case "${1:-all}" in
  all)
    start_infra
    # Run backend in background, mobile in foreground
    (cd backend && python manage.py migrate --run-syncdb 2>/dev/null || true; python manage.py runserver 0.0.0.0:8000) &
    BACKEND_PID=$!
    trap "kill $BACKEND_PID 2>/dev/null; $COMPOSE stop db redis" EXIT
    sleep 2
    echo "✅ Backend: http://localhost:8000/api/v1/"
    echo "✅ API docs: http://localhost:8000/api/v1/docs/"
    start_mobile
    ;;
  backend)
    start_backend
    ;;
  mobile)
    start_mobile
    ;;
  infra)
    start_infra
    ;;
  stop)
    echo "▶ Stopping infra..."
    $COMPOSE stop db redis
    ;;
  logs)
    $COMPOSE logs -f backend
    ;;
  shell)
    cd backend && python manage.py shell
    ;;
  test)
    cd backend && pytest -v
    ;;
  *)
    echo "Usage: $0 [all|backend|mobile|infra|stop|logs|shell|test]"
    exit 1
    ;;
esac
