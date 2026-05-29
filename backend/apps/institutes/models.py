"""Institute and trainer models (skeleton)."""
from django.conf import settings
from django.db import models


class Institute(models.Model):
    owner = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="institutes"
    )
    name = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    city = models.CharField(max_length=120, blank=True)  # Algerian wilaya/city
    logo_url = models.URLField(blank=True)
    is_verified = models.BooleanField(default=False)  # verified badge (MVP3)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self) -> str:
        return self.name


class TrainerProfile(models.Model):
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="trainer_profile"
    )
    institute = models.ForeignKey(
        Institute, on_delete=models.SET_NULL, null=True, blank=True, related_name="trainers"
    )
    headline = models.CharField(max_length=255, blank=True)
    bio = models.TextField(blank=True)

    def __str__(self) -> str:
        return f"TrainerProfile<{self.user_id}>"
