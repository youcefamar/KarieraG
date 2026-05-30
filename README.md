# Kariera

**AI-powered local training marketplace for Algerian students.**

Kariera helps students find the right professional course, compare institutes,
get AI-driven course recommendations, and build a learning/career roadmap.

> This repository was migrated from a legacy Flutter + Firebase app to a
> production-ready monorepo. See [`docs/00-current-audit.md`](docs/00-current-audit.md)
> for the audit and migration plan. The legacy Flutter app is archived under
> [`legacy/flutter-app/`](legacy/flutter-app) (kept for reference, not built).

## Tech stack

| Layer | Technology |
|-------|-----------|
| Mobile | React Native + Expo + TypeScript |
| Backend | Django + Django REST Framework |
| Database | PostgreSQL |
| Vector search | pgvector |
| AI / RAG | Embeddings over courses, institutes, reviews, FAQs, goals |
| Async jobs | Celery + Redis |
| Storage | S3-compatible / Cloudinary / Firebase Storage |
| Auth | JWT (SimpleJWT); optional Firebase Auth bridge |
| Admin | Django Admin first, custom dashboard later |
| Local dev | Docker Compose, `.env`, Makefile |

## Repository structure

```
kariera/
├── mobile/             # React Native Expo TypeScript app
├── web/                # Future admin dashboard (placeholder)
├── backend/            # Django + DRF API
│   ├── config/         # Project settings, urls, celery
│   ├── apps/           # Domain apps (accounts, courses, ai, ...)
│   ├── requirements/   # base / dev / prod
│   └── manage.py
├── infra/
│   ├── docker/         # Compose + Dockerfiles
│   └── scripts/
├── docs/               # Architecture, AI plan, roadmap, API design
├── legacy/             # Archived Flutter app (reference only, not built)
│   └── flutter-app/
├── .env.example
├── Makefile
└── README.md
```

## Documentation

| Doc | Purpose |
|-----|---------|
| [00-current-audit.md](docs/00-current-audit.md) | Legacy audit + migration plan |
| [01-product-vision.md](docs/01-product-vision.md) | Product vision & goals |
| [02-architecture.md](docs/02-architecture.md) | System architecture |
| [03-ai-rag-plan.md](docs/03-ai-rag-plan.md) | AI/RAG features & design |
| [04-database-models.md](docs/04-database-models.md) | Data model reference |
| [05-api-design.md](docs/05-api-design.md) | REST API design |
| [06-development-roadmap.md](docs/06-development-roadmap.md) | MVP phases |
| [07-deployment-plan.md](docs/07-deployment-plan.md) | Deployment plan |

## Local setup

Prerequisites: Docker + Docker Compose, Node 18+, Python 3.11+.

```bash
cp .env.example .env          # configure environment
make docker-up                # start postgres + redis + backend
make migrate                  # apply migrations
make createsuperuser          # create admin user
# API:        http://localhost:8000/api/v1/
# API docs:   http://localhost:8000/api/v1/docs/
# Django admin:http://localhost:8000/admin/
```

Mobile app:
```bash
make mobile                   # cd mobile && npm install && npx expo start
```

## Common commands

Run `make help` for the full list. Highlights:

| Command | Action |
|---------|--------|
| `make setup` | Install backend + mobile deps |
| `make backend` | Run Django dev server |
| `make mobile` | Start Expo dev server |
| `make migrate` | Apply DB migrations |
| `make test` | Run backend tests |
| `make lint` / `make format` | Lint / format backend |
| `make docker-up` / `make docker-down` | Start / stop local stack |

## Development phases

See [`docs/06-development-roadmap.md`](docs/06-development-roadmap.md). Summary:

- **MVP 1** — Auth, profiles, course CRUD, search, favorites, enrollment, notifications, Django Admin.
- **MVP 2** — AI course advisor, semantic search, match score, roadmap, institute dashboard.
- **MVP 3** — Reviews, verified badges, featured courses, payments, analytics.
- **MVP 4** — Advanced recommender, demand prediction, fraud detection, production deploy.

## Status

Foundation phase. Backend models and AI endpoints are **skeletons/mocked** with
clear `TODO`s. No full UI or real AI is implemented yet. See the bottom of the
setup summary for what is implemented vs. mocked.
