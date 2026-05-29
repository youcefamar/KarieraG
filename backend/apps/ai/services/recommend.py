"""Recommendation / advisor logic (skeleton).

The advisor is a RAG flow: retrieve candidate courses via semantic_search,
then assemble a grounded prompt (see prompts/) for the LLM. Mocked for now.
"""
from .search import semantic_search


def recommend_courses(*, goal: str, limit: int = 5):
    """Retrieve candidate courses for a student goal.

    TODO(MVP2): blend semantic similarity with student profile + popularity.
    """
    return semantic_search(goal, limit=limit)
