# RAG Guardrails

Notes that constrain every AI feature in the `ai` app. Keep these enforced in
`services/` and prompt templates, not just documented.

## Grounding
- **Retrieve, then generate.** Always pull candidate rows from `CourseEmbedding`
  (pgvector) before prompting. The LLM may only reference retrieved items.
- **No invented entities.** Courses, institutes, prices, dates, and contacts must
  come from the database. Prompts explicitly forbid fabrication.
- **Cite sources.** Responses should map each recommendation to a real course id.

## Input safety
- Treat user input as untrusted. Strip/escape before inserting into prompts to
  resist prompt injection ("ignore previous instructions").
- Cap input length; reject empty/oversized payloads at the serializer.

## Output safety
- Validate LLM output shape before returning (e.g., max N items, known course ids).
- Never return PII that wasn't already public in the catalog.
- Degrade gracefully: if retrieval is empty, return an honest "no match" instead
  of hallucinating.

## Cost & privacy
- `AI_PROVIDER=mock` by default — no external calls, no cost, no data egress.
- Real providers are opt-in via env. Log requests to `AIRecommendationLog` for
  evaluation, but avoid storing secrets or raw tokens.

## Determinism & evaluation
- Keep prompts in version-controlled `.txt` templates (this folder) so changes
  are reviewable.
- Log query + result for offline evaluation and future recommender training.
