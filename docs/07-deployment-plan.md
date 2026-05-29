# 07 — Deployment Plan

> Forward-looking. Production deploy lands in **MVP4**. This documents the target
> shape so the foundation stays deploy-ready. No production infra exists yet.

## Environments
| Env | Purpose | Settings module |
|-----|---------|-----------------|
| local | Docker Compose dev | `config.settings.dev` |
| staging | pre-prod mirror | `config.settings.prod` |
| production | live | `config.settings.prod` |

## Backend (production shape)
- **Server:** Gunicorn (`requirements/prod.txt`) behind a reverse proxy
  (Nginx / managed LB) terminating TLS.
- **Settings:** `config.settings.prod` (HSTS, secure cookies, SSL redirect,
  `SECURE_PROXY_SSL_HEADER` already set).
- **Static:** `collectstatic` → object storage / CDN or WhiteNoise.
- **Migrations:** run on release (`migrate --noinput`) before traffic switch.
- **Workers:** Celery worker (+ beat later) as separate processes/containers.

## Data services
- **PostgreSQL + pgvector:** managed Postgres with the `vector` extension
  (the `ai` migration enables it). Automated backups + PITR.
- **Redis:** managed instance for Celery broker/result backend.

## Configuration & secrets
- 12-factor env vars (`django-environ`). Never commit `.env`.
- Secrets via the platform's secret manager (not files in the image).
- Required prod vars: `SECRET_KEY`, `DATABASE_URL`, `REDIS_URL`,
  `ALLOWED_HOSTS`, `CORS_ALLOWED_ORIGINS`, AI/storage keys when enabled.

## Storage
- Course/profile images → S3-compatible / Cloudinary / Firebase Storage
  (env-selected via `STORAGE_BACKEND`).

## Mobile (Expo)
- Build & submit via **EAS Build** (iOS App Store / Google Play).
- OTA JS updates via EAS Update.
- `EXPO_PUBLIC_API_URL` points at the prod API per build profile.

## CI/CD (target)
1. Lint (`ruff`), format check, type checks.
2. Backend tests (`pytest`) against Postgres+pgvector service container.
3. Mobile `tsc --noEmit` + lint.
4. Build backend image; push to registry.
5. Deploy staging → smoke test (`/api/v1/health/`) → promote to prod.
6. Run migrations as a release step.

## Observability (target)
- Structured logging + request IDs.
- Error tracking (e.g. Sentry).
- Uptime probe on `/api/v1/health/`.
- Metrics on API latency, Celery queue depth, DB connections.

## Security checklist (pre-prod)
- [ ] `DEBUG=False`, real `SECRET_KEY`, locked `ALLOWED_HOSTS`/CORS
- [ ] TLS end-to-end; HSTS on
- [ ] Object-level authorization on course/institute writes
- [ ] Rate limiting on auth + AI endpoints
- [ ] Secrets in a manager, rotated; no secrets in images/repo
- [ ] DB backups tested (restore drill)

## Rollback
- Keep previous image tag; redeploy on failure.
- Migrations: prefer additive/backward-compatible; gate destructive changes.
