"""Enrollment / reservation models (skeleton)."""
from django.conf import settings
from django.db import models


class Enrollment(models.Model):
    class Status(models.TextChoices):
        PENDING = "pending", "Pending"
        CONFIRMED = "confirmed", "Confirmed"
        CANCELLED = "cancelled", "Cancelled"

    student = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="enrollments"
    )
    course = models.ForeignKey(
        "courses.Course", on_delete=models.CASCADE, related_name="enrollments"
    )
    session = models.ForeignKey(
        "courses.CourseSession", on_delete=models.SET_NULL, null=True, blank=True
    )
    status = models.CharField(max_length=10, choices=Status.choices, default=Status.PENDING)
    # Legacy registration-form fields captured at enrollment time.
    full_name = models.CharField(max_length=255, blank=True)
    level = models.CharField(max_length=120, blank=True)
    phone = models.CharField(max_length=32, blank=True)
    skills = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self) -> str:
        return f"Enrollment<{self.student_id}->{self.course_id}:{self.status}>"
