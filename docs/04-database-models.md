# 04 — Database Models

> Reference for the PostgreSQL schema (skeletons). Source of truth is
> `backend/apps/*/models.py`. Relationships shown; non-essential fields omitted.

## Entity relationships

```
User (accounts)
 ├─1:1─ StudentProfile (students)
 ├─1:1─ TrainerProfile (institutes) ──FK── Institute
 ├─1:N─ Institute (institutes, as owner)
 ├─1:N─ Favorite ──FK── Course
 ├─1:N─ Enrollment ──FK── Course / CourseSession
 ├─1:N─ Review ──FK── Course
 ├─1:N─ Notification
 ├─1:N─ AIRecommendationLog · SearchLog (recommendations)
 └─1:N─ PaymentRecord (payments) ──FK── Enrollment

Institute ─1:N─ Course ─1:N─ CourseSession
Course ─1:1─ CourseEmbedding (ai, pgvector)
Course ─FK── CourseCategory
```

## Models

### accounts.User  *(AUTH_USER_MODEL)*
`email` (unique, login), `username`, `role` (student | trainer |
institute_owner | admin), `phone`. Replaces legacy email-suffix role detection.

### students.StudentProfile
`user` (1:1), `goal` (legacy "objectif"), `level`, `bio`, `avatar_url`,
`created_at`.

### institutes.Institute
`owner` (FK User), `name`, `description`, `city`, `logo_url`,
`is_verified` (badge, MVP3), `created_at`.

### institutes.TrainerProfile
`user` (1:1), `institute` (FK, nullable), `headline`, `bio`.

### courses.CourseCategory
`name` (unique), `slug`. Seeded from legacy taxonomy (Development, Marketing,
Business, Design, Finance).

### courses.Course
`institute` (FK), `category` (FK, nullable), `title`, `about`, `program`,
`prerequisites`, `price_dzd`, `duration`, `location`, `mode` (onsite | online),
`status` (open | closed), `image_url`, `is_featured` (MVP3),
`created_at`, `updated_at`.

### courses.CourseSession
`course` (FK), `start_date`, `end_date`, `capacity`. A scheduled cohort.

### courses.Favorite
`user` (FK), `course` (FK), `created_at`. Unique (user, course).

### enrollments.Enrollment
`student` (FK User), `course` (FK), `session` (FK, nullable),
`status` (pending | confirmed | cancelled), plus registration-form fields
(`full_name`, `level`, `phone`, `skills`), `created_at`.

### reviews.Review
`course` (FK), `author` (FK User), `rating` (1–5), `comment`,
`sentiment` (filled by AI, MVP4), `created_at`. Unique (course, author).

### notifications.Notification
`recipient` (FK User), `title`, `message`, `status` (unread | read),
`data` (JSON deep-link), `created_at`.

### payments.PaymentRecord
`payer` (FK User, nullable), `enrollment` (FK, nullable), `amount_dzd`,
`commission_dzd`, `status` (pending | paid | refunded), `provider_ref`,
`created_at`. MVP3.

### recommendations.AIRecommendationLog
`user` (FK, nullable), `feature`, `request_payload` (JSON),
`response_payload` (JSON), `created_at`. For evaluation + future training.

### recommendations.SearchLog
`user` (FK, nullable), `query`, `is_semantic`, `result_count`, `created_at`.
Feeds demand prediction (MVP4).

### ai.CourseEmbedding
`course` (1:1), `embedding` (pgvector `VectorField`, dim = `EMBEDDING_DIM`),
`source_text`, `metadata` (JSON), `created_at`, `updated_at`.

## Notes
- All money in DZD (`DecimalField`).
- Currency/locale are Algeria-first.
- Migrations exist for all apps; the `ai` initial migration creates the pgvector
  extension (`VectorExtension`).
