# AGENTS.md — AI agent instructions for Kariera

This file governs how all AI agents (Claude, Codex, Kiro, Copilot, etc.) must
behave when working on this codebase. Read it before writing any code.

---

## What this project is

**Kariera** is an AI-powered training marketplace for Algerian students.

Students discover professional courses, compare institutes, get AI-driven
recommendations, and build a learning/career roadmap — all in a mobile app.

**Stack:** Django + DRF (backend) · React Native + Expo (mobile) · PostgreSQL +
pgvector (data + vector search) · SimpleJWT (auth) · Celery + Redis (async jobs)

**Users:** student · trainer · institute_owner · admin (role field on User model)

**AI features:** RAG over course catalog → course advisor, semantic search,
match score, roadmap generator. Provider is env-driven (`AI_PROVIDER`).
All AI endpoints are currently mocked. Real implementation comes in MVP 2.

---

## Non-negotiable rule: no hardcoding

Never hardcode in code what belongs in config or environment:

- Model names, provider names, API keys
- Role names, permission strings, enum values
- File paths, URLs, hostnames
- Prompt text (lives in `apps/ai/prompts/*.txt`)
- Thresholds, timeouts, limits
- Tool names or routing logic for specific tools

Before writing a literal value, ask: **does this belong in settings or config?**
If yes, read it from `django.conf.settings` or `environ.Env`.

Wrong:
```python
model = "gpt-4o"
if user.role == "trainer":
```

Right:
```python
model = settings.EMBEDDING_MODEL
if user.role == UserRole.TRAINER:  # enum defined once in models.py
```

---

## Architecture rules

### Thin views, fat services
Business logic lives in `apps/<app>/services.py`. Views only orchestrate.
Serializers only validate and serialize. Never put business logic in a view.

### Role-based permissions
`User.role` is the single source of truth. Permission classes read it.
Never check roles inline in views with `if request.user.role == "..."`.
Use or extend `apps/accounts/permissions.py`.

### AI is provider-agnostic
`apps/ai/services/embeddings.py::embed_text()` is the single entry point for
all embedding calls. It reads `settings.AI_PROVIDER` and dispatches.
Never call `openai.` directly outside this function.

The same applies to LLM calls — one service function, provider read from config.

### Prompts are files, not strings
All prompt templates live in `apps/ai/prompts/*.txt`.
Never write a prompt as a Python string literal in code.
Load them with the existing prompt loader utility.

### Config-driven AI tools
Every AI capability (advisor, search, match, roadmap, quality-check) is defined
by its service function + a prompt file + settings values.
To add a new AI feature: add a prompt file, add a service function, add an
endpoint. Do not add special-case routing in existing code.

---

## Adding a new feature — correct approach

1. Check if it fits an existing app (`courses`, `students`, `ai`, etc.).
2. Add the model field/migration if needed.
3. Add service logic in `services.py`.
4. Add serializer + view + URL.
5. Add tests in `apps/<app>/tests/`.
6. If it's an AI feature: add a prompt file, implement via `embed_text()` /
   LLM service, keep provider-agnostic.

Never:
- Add `if app_name == "..."` routing in core code
- Import a specific app's models in another app's views (use services)
- Add a new Django app for something that belongs in an existing one
- Hardcode the OpenAI model name anywhere except `settings/base.py` default

---

## Security rules

- Never hardcode `SECRET_KEY`, `DATABASE_URL`, `OPENAI_API_KEY`, or any
  credential. Use environment variables via `django-environ`.
- Never log personal data (name, email, phone). Log user IDs only.
- AI recommendations are decision support, not final answers. The UI must
  make this clear. Never present AI output as authoritative fact.
- All write endpoints require authentication. Public read endpoints are
  explicit exceptions with `AllowAny`.
- Rate-limit auth endpoints and AI endpoints (add when implementing, not later).

---

## Testing requirements

For every code change:
- Add or update tests in `apps/<app>/tests/`.
- Test the happy path, the permission-denied path, and invalid input.
- For AI services: test with `AI_PROVIDER=mock` (never call real APIs in tests).
- Run `pytest` and `ruff check .` before considering a task done.

Before finishing any task, scan the diff for:
- Hardcoded strings that belong in settings
- Direct `openai.` calls outside `embeddings.py`
- Role strings not using the enum
- Prompt text inside Python files
- Missing permission checks on write endpoints

---

## Final response requirement

When completing a task, state:

1. Which files were changed and why.
2. What belongs in config/settings vs. code, and where it lives.
3. How a future developer adds a similar feature without touching core code.
4. What tests were added.
5. Any known gaps or TODOs left intentionally.
