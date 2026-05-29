# 03 — AI / RAG Plan

> Foundation only. Services and endpoints are **mocked** (`AI_PROVIDER=mock`).
> This doc defines the features, the RAG architecture, and the rollout order.

## AI features

| # | Feature | MVP | Status |
|---|---------|-----|--------|
| 1 | AI Course Advisor | MVP2 | endpoint mocked |
| 2 | Semantic course search | MVP2 | service skeleton + endpoint mocked |
| 3 | Course match score | MVP2 | endpoint mocked |
| 4 | Learning roadmap generator | MVP2 | endpoint mocked |
| 5 | AI course quality checker (institutes) | MVP2/3 | endpoint mocked |
| 6 | AI chatbot per course | MVP3 | planned |
| 7 | Review sentiment analysis | MVP4 | `Review.sentiment` field ready |
| 8 | Low-quality / fraud detection | MVP4 | planned |
| 9 | Demand prediction for trainers | MVP4 | `SearchLog` logging ready |
| 10 | Personalized notifications | MVP4 | planned |

## RAG architecture

```
query ──▶ embed (services/embeddings) ──▶ retrieve top-k
                                          (CourseEmbedding + pgvector cosine)
                                                   │
                                                   ▼
                                   assemble grounded prompt (prompts/*.txt)
                                                   │
                                                   ▼
                                          LLM (mock now) ──▶ validated response
                                                   │
                                                   ▼
                                       log to AIRecommendationLog / SearchLog
```

- **Vector store:** pgvector column on `ai.CourseEmbedding`
  (`dimensions = settings.EMBEDDING_DIM`, default 1536).
- **Source text:** title + about + program + prerequisites
  (`services/indexing.build_source_text`).
- **Similarity:** cosine distance (`pgvector.django.CosineDistance`).
- **Grounding & safety:** see [`apps/ai/prompts/GUARDRAILS.md`](../backend/apps/ai/prompts/GUARDRAILS.md).

## Backend `ai` module

```
backend/apps/ai/
├── models.py                 # CourseEmbedding (pgvector VectorField)
├── views.py                  # 5 mocked endpoints
├── urls.py
├── services/
│   ├── embeddings.py         # embed_text() — mock vector now
│   ├── indexing.py           # build_source_text(), index_course()
│   ├── search.py             # semantic_search() via CosineDistance
│   └── recommend.py          # recommend_courses() (advisor retrieval)
└── prompts/
    ├── GUARDRAILS.md
    ├── course_advisor.txt
    ├── roadmap.txt
    └── course_quality.txt
```

### CourseEmbedding model
- `course` (OneToOne → courses.Course)
- `embedding` (VectorField, dim = EMBEDDING_DIM)
- `source_text` (text that was embedded)
- `metadata` (JSON)
- `created_at`, `updated_at`

## Endpoints (mocked)

| Method | Path | Returns |
|--------|------|---------|
| POST | `/api/v1/ai/course-advisor/` | `{goal, recommendations: [], mocked: true}` |
| GET  | `/api/v1/ai/semantic-search/?q=` | `{query, results: [], mocked: true}` |
| POST | `/api/v1/ai/course-match/` | `{score: null, mocked: true}` |
| POST | `/api/v1/ai/roadmap/` | `{goal, steps: [], mocked: true}` |
| POST | `/api/v1/ai/course-quality-check/` | `{quality_score: null, issues: [], mocked: true}` |

## Rollout

1. **Now (foundation):** model + services + prompts + mocked endpoints.
2. **MVP2:** implement `embed_text` for a real provider, a Celery task to index
   courses on save, and wire semantic-search/advisor/match/roadmap to services.
3. **MVP3:** per-course chatbot; quality checker in the institute dashboard.
4. **MVP4:** sentiment, fraud detection, demand prediction, personalized
   notifications; train a recommender on logged data.

## Provider strategy
- Default `mock` (no cost, no egress). Swap via `AI_PROVIDER`/`OPENAI_API_KEY`.
- A local/open model can implement the same `embed_text` contract later.
