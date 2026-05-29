"""Embedding service. Mock provider now; real provider behind AI_PROVIDER later."""
from django.conf import settings


def embed_text(text: str) -> list[float]:
    """Return an embedding vector for ``text``.

    TODO: when AI_PROVIDER == "openai", call the embeddings API with
    settings.EMBEDDING_MODEL. For now return a deterministic zero vector so the
    pipeline is wired without external calls or cost.
    """
    if settings.AI_PROVIDER == "mock":
        return [0.0] * settings.EMBEDDING_DIM
    raise NotImplementedError(f"AI_PROVIDER={settings.AI_PROVIDER} not implemented")
