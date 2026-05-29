"""Semantic search over CourseEmbedding using pgvector cosine distance."""
from pgvector.django import CosineDistance

from apps.ai.models import CourseEmbedding

from .embeddings import embed_text


def semantic_search(query: str, limit: int = 10):
    """Return courses ranked by embedding similarity to ``query``.

    TODO(MVP2): add filters (category, city, price) and log to SearchLog.
    """
    vector = embed_text(query)
    return (
        CourseEmbedding.objects.annotate(distance=CosineDistance("embedding", vector))
        .order_by("distance")
        .select_related("course")[:limit]
    )
