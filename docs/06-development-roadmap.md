# 06 — Development Roadmap

> Foundation-first. Build a clean base (done), then ship value in MVP slices.
> Each MVP is releasable. AI lands in MVP2, monetization in MVP3.

## Phase 0 — Foundation (current) ✅
Monorepo, Django backend skeleton (10 apps, models, `/api/v1/`, OpenAPI),
RN/Expo mobile skeleton, AI/RAG scaffolding (mocked), Docker, docs.
No full UI, no real AI yet.

## MVP 1 — Core marketplace (no AI)
Goal: a usable catalog where students discover and enroll, institutes manage courses.
- Auth: register/login/refresh/me (roles enforced)
- Student profile (`/students/me/`)
- Institute profile + CRUD
- Course CRUD + list filters (category, city, mode, price)
- Course search (DB filters; non-semantic)
- Course details
- Favorites (`/favorites/me/`)
- Enrollment / reservation + registration form
- Basic notifications (new course in student's goal category)
- Django Admin for moderation
- Tests for each endpoint; object-level permissions (own institute)

## MVP 2 — AI layer
Goal: personalized discovery and guidance.
- Real `embed_text` provider (env-driven) + Celery indexing on course save
- Semantic course search (wire `/ai/semantic-search/` to pgvector)
- AI course advisor (RAG over catalog)
- Course match score
- Learning roadmap generator
- Better institute dashboard (manage courses, see enrollments)

## MVP 3 — Trust & monetization
Goal: trust signals and revenue.
- Reviews + ratings (with moderation)
- Verified institute badge
- Featured courses
- Payment / commission tracking
- Analytics for institutes
- AI course quality checker in dashboard
- Per-course AI chatbot

## MVP 4 — Intelligence & scale
Goal: data-driven growth and production hardening.
- Advanced ML recommender (trained on logged data)
- Demand prediction for trainers (from `SearchLog`)
- Fraud / low-quality course detection
- Review sentiment analysis
- Personalized notifications
- Production deployment (see `07-deployment-plan.md`), monitoring, CI/CD

## Cross-cutting (every MVP)
- Tests + lint + type checks green before merge
- Small, reviewable PRs
- Docs updated alongside code
- No secrets in the repo; env-driven config

## Legacy migration (parallel track)
- Approve archive move (audit §3) → `legacy/flutter-app/`
- Optional Firestore → PostgreSQL ETL (`infrastructure/scripts/`) if data is kept
