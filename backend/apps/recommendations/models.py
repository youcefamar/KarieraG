"""Logging models for AI recommendations and search (skeleton).

Used later for analytics, demand prediction, and recommender training.
"""
from django.conf import settings
from django.db import models


class AIRecommendationLog(models.Model):
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, related_name="ai_logs"
    )
    feature = models.CharField(max_length=50)  # e.g. "course-advisor", "course-match"
    request_payload = models.JSONField(default=dict, blank=True)
    response_payload = models.JSONField(default=dict, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self) -> str:
        return f"AIRecommendationLog<{self.feature}>"


class SearchLog(models.Model):
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, blank=True,
        related_name="search_logs",
    )
    query = models.CharField(max_length=512)
    is_semantic = models.BooleanField(default=False)
    result_count = models.PositiveIntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self) -> str:
        return f"SearchLog<{self.query[:40]}>"
