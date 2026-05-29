"""AI models. CourseEmbedding stores pgvector embeddings for semantic search."""
from django.conf import settings
from django.db import models
from pgvector.django import VectorField


class CourseEmbedding(models.Model):
    course = models.OneToOneField(
        "courses.Course", on_delete=models.CASCADE, related_name="embedding"
    )
    embedding = VectorField(dimensions=settings.EMBEDDING_DIM)
    source_text = models.TextField()  # text that was embedded
    metadata = models.JSONField(default=dict, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self) -> str:
        return f"CourseEmbedding<{self.course_id}>"
