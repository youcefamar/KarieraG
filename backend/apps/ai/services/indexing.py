"""Course indexing: build source text and upsert CourseEmbedding rows."""
from apps.ai.models import CourseEmbedding

from .embeddings import embed_text


def build_source_text(course) -> str:
    """Flatten a course into the text we embed."""
    parts = [course.title, course.about, course.program, course.prerequisites]
    return "\n".join(p for p in parts if p)


def index_course(course) -> CourseEmbedding:
    """Create/refresh the embedding for a single course.

    TODO: call this from a Celery task on Course save/update (Phase 4+).
    """
    source = build_source_text(course)
    embedding = embed_text(source)
    obj, _ = CourseEmbedding.objects.update_or_create(
        course=course,
        defaults={"embedding": embedding, "source_text": source},
    )
    return obj
