# 05 — API Design

> REST API, versioned under `/api/v1/`. Auth is JWT (SimpleJWT) Bearer tokens.
> Endpoints marked **(impl)** exist today; others are **(planned)** for the MVP
> noted in [`06-development-roadmap.md`](06-development-roadmap.md).

## Conventions
- Base URL: `/api/v1/`
- Auth: `Authorization: Bearer <access>` (except register/login/health/docs).
- Content type: JSON. Lists are paginated (DRF default page params).
- Errors: DRF standard (`{"detail": ...}` or field errors), proper status codes.
- OpenAPI schema: `/api/v1/schema/` · Swagger UI: `/api/v1/docs/`.

## Auth
| Method | Path | Body / notes | Status |
|--------|------|--------------|--------|
| POST | `/auth/register/` | email, username, password, role (not admin) | impl |
| POST | `/auth/login/` | email, password → `{access, refresh}` | impl |
| POST | `/auth/refresh/` | `{refresh}` → `{access}` | impl |
| GET | `/auth/me/` | current user | impl |
| PATCH | `/auth/me/` | update username/phone | impl |

## Students
| Method | Path | Notes | Status |
|--------|------|-------|--------|
| GET | `/students/me/` | current student profile | planned (MVP1) |
| PATCH | `/students/me/` | goal, level, bio, avatar | planned (MVP1) |

## Institutes
| Method | Path | Notes | Status |
|--------|------|-------|--------|
| GET | `/institutes/` | list/search institutes | planned (MVP1) |
| POST | `/institutes/` | create (institute_owner) | planned (MVP1) |
| GET | `/institutes/{id}/` | detail | planned (MVP1) |

## Courses
| Method | Path | Notes | Status |
|--------|------|-------|--------|
| GET | `/courses/` | list + filters (category, city, mode) | impl (CRUD), filters planned |
| POST | `/courses/` | create (trainer/owner) | impl |
| GET | `/courses/{id}/` | detail | impl |
| PATCH | `/courses/{id}/` | update (owner only — TODO perm) | impl |
| DELETE | `/courses/{id}/` | delete (owner only — TODO perm) | impl |
| GET | `/courses/{id}/similar/` | similar courses (semantic) | impl (mocked) |

## Enrollments
| Method | Path | Notes | Status |
|--------|------|-------|--------|
| POST | `/courses/{id}/enroll/` | enroll + registration form | planned (MVP1) |
| GET | `/enrollments/me/` | my enrollments | planned (MVP1) |
| PATCH | `/enrollments/{id}/status/` | confirm/cancel | planned (MVP1) |

## Favorites
| Method | Path | Notes | Status |
|--------|------|-------|--------|
| POST | `/courses/{id}/favorite/` | add favorite | impl |
| DELETE | `/courses/{id}/favorite/` | remove favorite | impl |
| GET | `/favorites/me/` | my favorites | planned (MVP1) |

## Reviews
| Method | Path | Notes | Status |
|--------|------|-------|--------|
| POST | `/courses/{id}/reviews/` | add review (1–5 + comment) | planned (MVP3) |
| GET | `/courses/{id}/reviews/` | list reviews | planned (MVP3) |

## Notifications
| Method | Path | Notes | Status |
|--------|------|-------|--------|
| GET | `/notifications/` | my notifications | planned (MVP1) |
| PATCH | `/notifications/{id}/` | mark read | planned (MVP1) |

## AI (mocked)
| Method | Path | Notes | Status |
|--------|------|-------|--------|
| POST | `/ai/course-advisor/` | `{goal}` → recommendations | impl (mocked) |
| GET | `/ai/semantic-search/?q=` | semantic results | impl (mocked) |
| POST | `/ai/course-match/` | goal↔course similarity score | impl (mocked) |
| POST | `/ai/roadmap/` | `{goal, level}` → ordered steps | impl (mocked) |
| POST | `/ai/course-quality-check/` | listing quality review | impl (mocked) |

## Admin
- Django Admin at `/admin/` for MVP1–2 (users, institutes, courses, etc.).
- Custom dashboard (`web/`) deferred to MVP3.

## System
| Method | Path | Notes | Status |
|--------|------|-------|--------|
| GET | `/health/` | liveness `{status: ok}` | impl |
| GET | `/schema/` · `/docs/` | OpenAPI + Swagger UI | impl |

## Authorization model
Permissions derive from `User.role` (`student`, `trainer`, `institute_owner`,
`admin`) — never email suffix. Course/institute writes require
trainer/owner/admin (`apps.accounts.permissions`); object-level "owns this
institute" checks are a TODO for MVP1.
