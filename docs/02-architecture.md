# 02 — System Architecture

## High-level diagram

```
┌──────────────────────┐         ┌──────────────────────┐
│  Mobile (Expo/RN/TS)  │         │  admin-web (future)   │
└──────────┬───────────┘         └──────────┬───────────┘
           │  HTTPS + JWT (Bearer)          │
           └───────────────┬────────────────┘
                           ▼
              ┌─────────────────────────┐
              │  Django REST Framework   │   /api/v1/
              │  - views (thin)          │
              │  - serializers           │
              │  - services (logic)      │
              │  - permissions (roles)   │
              └────┬──────────┬─────────┘
                   │          │
        ┌──────────▼──┐   ┌───▼────────────┐
        │ PostgreSQL   │   │ Redis + Celery │
        │ + pgvector   │   │ (async jobs:   │
        │ (data +      │   │  embeddings,   │
        │  embeddings) │   │  notifications)│
        └──────────────┘   └────────────────┘
                   │
          ┌────────▼─────────┐      ┌──────────────────────┐
          │  ai app (RAG)    │◀────▶│ Embedding provider    │
          │  retrieval +     │      │ (mock now; OpenAI/    │
          │  prompt assembly │      │  local model later)   │
          └──────────────────┘      └──────────────────────┘
                   │
          ┌────────▼─────────┐
          │ Object storage   │  S3 / Cloudinary / Firebase
          │ (images, files)  │
          └──────────────────┘
```

## Principles
- **API-first**: one versioned REST API (`/api/v1/`) serves all clients.
- **Thin views, fat services**: business logic lives in `apps/<app>/services.py`,
  never inside views or serializers. Views orchestrate; serializers validate.
- **Role-based authorization**: a single `User.role` enum
  (`student`, `trainer`, `institute_owner`, `admin`) drives DRF permissions.
  No email-suffix logic.
- **Async by default for heavy work**: embedding generation, indexing, and
  notification fan-out run in Celery tasks, not request/response.
- **Vector search in the DB**: pgvector keeps embeddings next to relational data
  so semantic search and filters compose in one query.

## Backend layout (per app)
```
apps/<name>/
├── models.py          # data model skeletons
├── admin.py           # Django Admin registration
├── serializers.py     # DRF (de)serialization + validation
├── services.py        # business logic (pure-ish, testable)
├── views.py           # thin DRF viewsets/views
├── urls.py            # app router
├── permissions.py     # (where needed) role checks
└── tests/             # pytest tests
```

## Request lifecycle (example: enroll)
1. `POST /api/v1/courses/{id}/enroll/` → `CourseViewSet.enroll`.
2. View calls `enrollments.services.enroll_student(user, course)`.
3. Service validates capacity/role, creates `Enrollment`, enqueues a
   notification Celery task.
4. Serializer returns the created enrollment.

## Environments
- **Local**: Docker Compose (backend, postgres+pgvector, redis, pgadmin, mailpit).
- **Prod** (later): see `07-deployment-plan.md`.

## Cross-cutting
- **Auth**: SimpleJWT access/refresh tokens. Optional Firebase Auth bridge for
  legacy users (documented, not built yet).
- **Docs**: drf-spectacular serves OpenAPI schema + Swagger UI at `/api/v1/docs/`.
- **Config**: 12-factor via environment variables (`django-environ`).
- **Observability** (later): structured logging, request IDs, Sentry.
