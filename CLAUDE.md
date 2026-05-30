# CLAUDE.md — Kariera codebase context

Single source of truth for navigating the Kariera codebase.
Read this fully before answering any question about architecture, code
location, or conventions.

---

## What this project is

**Kariera** is an AI-powered training marketplace for Algerian students.

Students discover professional courses (graphic design, coding, languages, etc.
taught by real institutes), compare institutes, get AI-driven recommendations,
and build a learning/career roadmap — all in a mobile app.

This is a **marketplace**, not an LMS. Courses are real-world, offline/in-person
training. The app connects students to institutes; it does not deliver content.

**Stack:**
- Backend: Django 5 + DRF, Python 3.11
- Mobile: React Native + Expo + TypeScript
- Database: PostgreSQL + pgvector (one DB, no MongoDB, no Redis)
- Auth: SimpleJWT (JWT access/refresh tokens)
- Async jobs: Celery + Redis (on-demand background tasks: embeddings, notifications)
- AI/RAG: provider-agnostic via `AI_PROVIDER` env var (mocked in dev)

---

## Users & roles

`User.role` is a single enum field — the source of truth for all permissions:

| Role | Can do |
|------|--------|
| `student` | discover courses, enroll, favorites, get AI recommendations |
| `trainer` | publish and manage courses |
| `institute_owner` | manage institute profile + its trainers/courses |
| `admin` | moderate content, verify institutes, full Django Admin access |

Never check roles as raw strings. Always use the `UserRole` enum from
`apps/accounts/models.py`.

---

## Repository structure

```
kariera/
├── backend/
│   ├── config/
│   │   ├── settings/
│   │   │   ├── base.py       # all shared settings
│   │   │   ├── dev.py        # DEBUG=True, CORS open
│   │   │   └── prod.py       # gunicorn, whitenoise, sentry, storage
│   │   ├── urls.py           # root URL conf (/api/v1/)
│   │   ├── views.py          # health check endpoint
│   │   ├── wsgi.py
│   │   └── asgi.py
│   ├── apps/
│   │   ├── accounts/         # User model, JWT auth, permissions
│   │   ├── students/         # student profile, favorites
│   │   ├── institutes/       # institute profiles
│   │   ├── courses/          # course CRUD, search, categories
│   │   ├── enrollments/      # enrollment / reservation
│   │   ├── reviews/          # ratings and reviews
│   │   ├── notifications/    # in-app notifications
│   │   ├── recommendations/  # non-AI recommendation logic
│   │   ├── payments/         # payment tracking (MVP3)
│   │   ├── ai/               # RAG: embeddings, search, advisor, roadmap
│   │   └── scheduler/        # APScheduler setup (periodic jobs)
│   ├── requirements/
│   │   ├── base.txt          # shared deps
│   │   ├── dev.txt           # + pytest, ruff, black
│   │   └── prod.txt          # + gunicorn, whitenoise, sentry, storages
│   ├── Procfile              # for Railway/Render: web + release commands
│   └── manage.py
├── mobile/                   # React Native Expo TypeScript app
├── infra/
│   ├── docker/
│   │   ├── docker-compose.local.yml   # db + backend (no redis, no worker)
│   │   ├── Dockerfile.backend
│   │   └── entrypoint.backend.sh
│   └── scripts/
├── docs/                     # architecture, AI plan, roadmap, API design
├── .env.example              # all env vars documented with comments
├── AGENTS.md                 # rules for all AI agents
├── CLAUDE.md                 # this file
├── Makefile
└── run.sh                    # fast local dev launcher
```

---

## App structure (every app follows this)

```
apps/<name>/
├── models.py          # data model
├── admin.py           # Django Admin registration
├── serializers.py     # DRF validation + serialization
├── services.py        # ALL business logic lives here
├── views.py           # thin DRF viewsets — orchestrate only
├── urls.py            # app router
├── permissions.py     # role checks (where needed)
└── tests/             # pytest tests
```

---

## AI / RAG architecture

```
apps/ai/
├── models.py                 # CourseEmbedding (pgvector VectorField)
├── views.py                  # 5 endpoints (mocked until MVP2)
├── urls.py
├── services/
│   ├── embeddings.py         # embed_text() — SINGLE entry point for all embeddings
│   ├── indexing.py           # build_source_text(), index_course()
│   ├── search.py             # semantic_search() via CosineDistance
│   └── recommend.py          # recommend_courses() (advisor retrieval + prompt)
└── prompts/
    ├── course_advisor.txt
    ├── roadmap.txt
    └── course_quality.txt
```

**How RAG works:**
1. Student asks a question → `embed_text(question)` → vector
2. pgvector cosine search against `CourseEmbedding` → top-k courses
3. Assemble prompt from `prompts/*.txt` + retrieved course text
4. Send to LLM (provider from `settings.AI_PROVIDER`)
5. Return structured response

**Current state:** all 5 AI endpoints return mocked data (`AI_PROVIDER=mock`).
Real implementation is MVP2.

**AI endpoints:**
- `POST /api/v1/ai/course-advisor/`
- `GET  /api/v1/ai/semantic-search/?q=`
- `POST /api/v1/ai/course-match/`
- `POST /api/v1/ai/roadmap/`
- `POST /api/v1/ai/course-quality-check/`

---

## Key settings (base.py)

```python
AI_PROVIDER       # "mock" | "openai" | any future provider
OPENAI_API_KEY    # only used when AI_PROVIDER=openai
EMBEDDING_MODEL   # default: "text-embedding-3-small"
EMBEDDING_DIM     # default: 1536
STORAGE_BACKEND   # "local" | "s3" | "cloudinary"
```

Never hardcode these values in code. Always read from `settings.*`.

---

## Scheduling (Celery + Redis)

Celery handles on-demand background tasks triggered by user actions (e.g.
generate AI embedding when a course is saved) and periodic jobs.

- `config/celery.py` — Celery app, autodiscovers tasks from all apps
- `config/__init__.py` — exposes `celery_app` so Django loads it on startup
- Add tasks in `apps/<app>/tasks.py`, decorate with `@shared_task`
- Redis is the broker (`CELERY_BROKER_URL`) and result backend (`CELERY_RESULT_BACKEND`)
- Worker runs as a separate container in docker-compose (`celery -A config worker`)

Example — index course embedding on save:
```python
# apps/courses/models.py
from django.db.models.signals import post_save
from django.dispatch import receiver

@receiver(post_save, sender=Course)
def trigger_embedding(sender, instance, **kwargs):
    from apps.ai.tasks import index_course_task
    index_course_task.delay(instance.id)
```

---

## Authentication

SimpleJWT. No Keycloak, no Authentik, no Auth0.

- `POST /api/v1/auth/login/` → access + refresh tokens
- `POST /api/v1/auth/refresh/` → new access token
- All write endpoints require `Authorization: Bearer <token>`
- Public read endpoints explicitly use `AllowAny`

Social login (Google/Apple) can be added later with `django-allauth` — no
new auth server needed.

---

## Deployment

**Platform:** Railway or Render (Postgres with pgvector supported).

**Key files:**
- `backend/Procfile` — `web:` gunicorn, `release:` migrate + collectstatic
- `config/settings/prod.py` — WhiteNoise static, S3/Cloudinary storage, Sentry
- `.env.example` — all required prod vars documented

**Mobile:** EAS Build → App Store / Google Play.
`EXPO_PUBLIC_API_URL` points at the live API per build profile.

---

## URL structure

All API routes under `/api/v1/`:

| Path | App |
|------|-----|
| `auth/login/` | SimpleJWT |
| `auth/refresh/` | SimpleJWT |
| `auth/` | accounts |
| `students/` | students |
| `institutes/` | institutes |
| `courses/` | courses |
| `enrollments/` | enrollments |
| `reviews/` | reviews |
| `notifications/` | notifications |
| `ai/` | ai |
| `health/` | config.views.health_check |
| `docs/` | drf-spectacular Swagger UI |
| `schema/` | drf-spectacular OpenAPI schema |

---

## Development commands

```bash
./run.sh              # start infra (db) + backend + mobile
./run.sh backend      # backend only
./run.sh mobile       # mobile only
./run.sh test         # pytest
./run.sh shell        # Django shell
make docker-up        # start docker stack
make migrate          # apply migrations
make lint             # ruff check
make test             # pytest via docker
```

---

## Non-negotiable rules (same as AGENTS.md)

1. **No hardcoding** — model names, role strings, prompts, paths → settings/config
2. **Thin views, fat services** — business logic in `services.py` only
3. **Role enum** — always `UserRole.TRAINER`, never `"trainer"`
4. **Prompts are files** — `apps/ai/prompts/*.txt`, never Python strings
5. **One embedding entry point** — `embed_text()` only, never `openai.` directly
6. **Tests required** — happy path + permission denied + invalid input
7. **AI_PROVIDER=mock in tests** — never call real APIs in tests

---

## MVP phases

| Phase | Goal | Status |
|-------|------|--------|
| Foundation | skeleton, models, Docker, AI mocked | ✅ done |
| MVP 1 | auth, profiles, course CRUD, search, enrollment, notifications | 🔨 building |
| MVP 2 | real AI: embeddings, semantic search, advisor, roadmap | planned |
| MVP 3 | reviews, verified badges, payments, analytics | planned |
| MVP 4 | advanced ML, fraud detection, production deploy | planned |
