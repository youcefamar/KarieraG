# Local development (Docker)

Local stack for the Kariera backend. Run all commands from the **repo root**.

## Services

| Service | Image | Port | Notes |
|---------|-------|------|-------|
| `db` | `pgvector/pgvector:pg16` | 5432 | Postgres + pgvector extension |
| `redis` | `redis:7-alpine` | 6379 | Celery broker / result backend |
| `backend` | built from `Dockerfile.backend` | 8000 | Django + DRF, auto-migrates on boot |
| `worker` | built from `Dockerfile.backend` | — | Celery worker |
| `pgadmin` | `dpage/pgadmin4` | 5050 | optional (`--profile tools`) |
| `mailpit` | `axllent/mailpit` | 8025 / 1025 | optional (`--profile tools`) |

## First run

```bash
cp .env.example .env          # then edit secrets if needed
make docker-up                # build + start db, redis, backend, worker
make createsuperuser          # create an admin login
```

The `backend` entrypoint waits for Postgres and runs `migrate` automatically,
including the pgvector extension (created by the `ai` initial migration).

URLs:
- API:        http://localhost:8000/api/v1/
- API docs:   http://localhost:8000/api/v1/docs/
- Admin:      http://localhost:8000/admin/

## Optional tools

```bash
docker compose -f infrastructure/docker/docker-compose.local.yml \
  --profile tools up -d pgadmin mailpit
# pgAdmin: http://localhost:5050   Mailpit: http://localhost:8025
```

## Common commands

| Command | Action |
|---------|--------|
| `make docker-up` | Build + start the stack |
| `make docker-down` | Stop the stack |
| `make migrate` | Run migrations in the backend container |
| `make makemigrations` | Create migrations |
| `make createsuperuser` | Create a Django admin user |
| `make test` | Run pytest in the backend container |
| `make logs` | Tail backend logs |

## Mobile

The mobile app runs best on the host (device/simulator access):
```bash
make mobile          # cd mobile && npm install && npx expo start
```
A `Dockerfile.mobile` is provided for parity but not part of the default stack.

## Notes
- Tests require this stack (pgvector); run them with `make test`, not locally.
- `pgdata` is a named volume — `make docker-down` keeps data; add `-v` to wipe.
