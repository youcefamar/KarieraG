# Infrastructure scripts

Operational helper scripts (DB backups, seeding, data migration from the legacy
Firestore export, embedding reindex, etc.).

Planned (not yet implemented):
- `seed_categories.py` — seed `CourseCategory` from the legacy taxonomy.
- `migrate_firestore.py` — ETL legacy Firestore export → PostgreSQL.
- `reindex_embeddings.py` — rebuild `CourseEmbedding` rows.

Keep scripts idempotent and environment-driven (no hardcoded secrets).
