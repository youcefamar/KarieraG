# 00 — Current Repository Audit

> Phase 0 deliverable. Snapshot of the legacy Kariera app and the plan to evolve
> it into a production-ready, AI-powered training marketplace for Algeria.

## 1. What exists now

The legacy **Flutter + Firebase** mobile application now lives under
`legacy/flutter-app/` (archived — see §3). It originally sat at the repo root;
the paths below are relative to the archive directory.

| Area | Detail |
|------|--------|
| Framework | Flutter (Dart SDK `>=3.2.6 <4.0.0`) |
| Backend | Firebase (Auth, Cloud Firestore, Storage) — no custom server |
| Entry point | `lib/main.dart` |
| Pages | ~25 screens under `lib/Pages/` (auth, home, search, favorites, course details, enrollment form, profile, notifications, settings, trainer dashboard, add/edit course) |
| Models | `lib/Models/` (static `FormationModel`, `infosModel`) |
| Components | `lib/Components/` (theme, text fields, tiles, helpers) |
| Auth providers | Email/password, Google Sign-In, Facebook |
| Assets | `assets/` — Lottie JSON animations + images (~3 MB) |
| Platforms | android, ios, web, windows, macos, linux scaffolds |
| Config files | `pubspec.yaml`, `analysis_options.yaml`, `firebase_options.dart`, `google-services.json`, `GoogleService-Info.plist` |
| VCS | Git, branch `gikawa`, remote `github.com/Mounibyte/KarieraG` |

### Legacy data model (Firestore collections)
- `users` — username, email, objectif, imageUrl
- `formations` — title, prix, about, durée, prérequis, nomInstitut, categorie, programme, localisation, date, imageUrl, formateurPoster, état
- `formations/{id}/mes_formulaires` — student enrollment forms
- `favoris/{email}/mes_favoris` — favorites
- `notifications` — email, formationId, status, message, timestamp

### Critical legacy issues
- **Authorization by email suffix**: trainers are detected by `email.endsWith('@kariera.com')` in `main.dart`. This is insecure and must be replaced with real roles.
- **No backend layer**: all business logic lives client-side against Firestore, so rules, validation, and AI cannot be enforced server-side.
- **No semantic/AI capability**: search is a Firestore `>=`/`<=` prefix match on `title`.
- **Committed secrets**: `google-services.json`, `GoogleService-Info*.plist` are in the repo.
- **Schema in French, untyped**: field names mix French/English; documents are schemaless.

## 2. What should be reused

- **Product domain knowledge & UX flows** — the screen inventory maps almost 1:1 to the new mobile screens.
- **Assets** (Lottie animations, images) — can be copied into `mobile/assets/` selectively.
- **Firebase Storage** — optional, remains a valid storage backend option (see `07-deployment-plan.md`).
- **Category taxonomy** (Development, Marketing, Business, Design, Finance) — seed data for `CourseCategory`.
- **Domain copy** (French UI strings) — reusable for i18n.

## 3. What should be archived

The entire legacy Flutter app has been moved (not deleted) into
`legacy/flutter-app/` via `git mv`, preserving history. The repo root now cleanly
exposes the new stack: `backend/`, `apps/` (frontend), `infrastructure/`, `docs/`.

**Archive executed:**
```bash
mkdir legacy/flutter-app
git mv lib android ios web windows macos linux test assets legacy/flutter-app/
git mv pubspec.yaml pubspec.lock analysis_options.yaml .metadata legacy/flutter-app/
git mv "GoogleService-Info.plist" "GoogleService-Info (1).plist" legacy/flutter-app/
git mv APP_DESCRIPTION.md legacy/flutter-app/
```
The move is reversible (`git mv` back) and retains full git history. `legacy/`
is excluded from new tooling (lint/test/build target only `backend/` and
`apps/`).
Until that move is approved, the new stack is added **alongside** the Flutter app
in new top-level folders (`apps/`, `backend/`, `infrastructure/`, `docs/`) so
nothing breaks.

> Note: the proposed structure uses `kariera/` as the project root. This repo's
> existing root (`KarieraG/`) is treated as that root; new folders are created
> directly under it.

## 4. What should be rebuilt

Everything functional is rebuilt on the new stack:

| Legacy | Rebuilt as |
|--------|-----------|
| Flutter UI | React Native + Expo + TypeScript (`mobile/`) |
| Firestore documents | PostgreSQL relational models (`backend/apps/*`) |
| Client-side logic | Django REST Framework API (`/api/v1/`) |
| Email-suffix roles | `User.role` enum: student / trainer / institute_owner / admin |
| Prefix search | pgvector semantic search + filtered SQL |
| (none) | AI: course advisor, match score, roadmap, quality check |
| Firebase Auth only | JWT (SimpleJWT); Firebase Auth optional bridge |

## 5. Risks of direct migration

- **Data migration**: Firestore (NoSQL, French, schemaless) → PostgreSQL (relational, typed) requires an ETL script and field-name normalization. Low data volume today makes this cheap if done early.
- **Auth identity continuity**: existing Firebase UIDs won't map to new JWT users unless a bridge or one-time migration is built. Acceptable if user base is small.
- **Security debt**: email-suffix authorization, committed secrets, and client-trusted writes must not be carried over.
- **Scope creep**: rebuilding UI and inventing AI simultaneously risks a half-working app. Mitigation: foundation-first (this plan), then MVP1 (no AI), then layer AI in MVP2.
- **Two stacks during transition**: keeping Flutter + new stack in one repo can confuse tooling. Mitigation: the archive move in §3.

## 6. Recommended final architecture

```
React Native (Expo, TS)  ──HTTPS/JWT──▶  Django REST Framework (/api/v1/)
                                              │
                  ┌───────────────────────────┼───────────────────────────┐
                  ▼                            ▼                           ▼
            PostgreSQL + pgvector        Redis + Celery              Object storage
        (relational data + embeddings)  (async jobs, indexing)    (S3 / Cloudinary /
                                                                    Firebase Storage)
                                              │
                                              ▼
                                     AI/RAG layer (ai app):
                              embeddings · semantic search · advisor
```

- **API-first**: mobile and future `admin-web` share one versioned REST API.
- **Service layer**: business logic in `services.py` per app, not in views.
- **Admin**: Django Admin first; custom dashboard later (`web/` placeholder).
- **Deployment-ready**: Docker Compose for local dev, env-var config, CI-ready layout.

See `02-architecture.md` for the full target architecture.
