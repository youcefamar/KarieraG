"""Course domain models (skeleton)."""
from django.conf import settings
from django.db import models


class CourseCategory(models.Model):
    name = models.CharField(max_length=120, unique=True)
    slug = models.SlugField(max_length=140, unique=True)

    class Meta:
        verbose_name_plural = "course categories"

    def __str__(self) -> str:
        return self.name


class Course(models.Model):
    class Mode(models.TextChoices):
        ONSITE = "onsite", "On-site"
        ONLINE = "online", "Online"

    class Status(models.TextChoices):
        OPEN = "open", "Open"
        CLOSED = "closed", "Closed"

    institute = models.ForeignKey(
        "institutes.Institute", on_delete=models.CASCADE, related_name="courses"
    )
    category = models.ForeignKey(
        CourseCategory, on_delete=models.SET_NULL, null=True, related_name="courses"
    )
    title = models.CharField(max_length=255)
    about = models.TextField(blank=True)
    program = models.TextField(blank=True)
    prerequisites = models.TextField(blank=True)
    price_dzd = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    duration = models.CharField(max_length=120, blank=True)
    location = models.CharField(max_length=255, blank=True)
    mode = models.CharField(max_length=10, choices=Mode.choices, default=Mode.ONSITE)
    status = models.CharField(max_length=10, choices=Status.choices, default=Status.OPEN)
    image_url = models.URLField(blank=True)
    is_featured = models.BooleanField(default=False)  # MVP3
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self) -> str:
        return self.title


class CourseSession(models.Model):
    """A scheduled run of a course (cohort)."""

    course = models.ForeignKey(Course, on_delete=models.CASCADE, related_name="sessions")
    start_date = models.DateField(null=True, blank=True)
    end_date = models.DateField(null=True, blank=True)
    capacity = models.PositiveIntegerField(null=True, blank=True)

    def __str__(self) -> str:
        return f"{self.course_id} @ {self.start_date}"


class Favorite(models.Model):
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="favorites"
    )
    course = models.ForeignKey(Course, on_delete=models.CASCADE, related_name="favorited_by")
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ("user", "course")

    def __str__(self) -> str:
        return f"Favorite<{self.user_id}->{self.course_id}>"
