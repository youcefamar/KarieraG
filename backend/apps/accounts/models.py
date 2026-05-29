"""Accounts models. Custom User with an explicit role enum.

Replaces the legacy `email.endsWith('@kariera.com')` trainer detection.
"""
from django.contrib.auth.models import AbstractUser
from django.db import models

from .managers import UserManager


class Role(models.TextChoices):
    STUDENT = "student", "Student"
    TRAINER = "trainer", "Trainer"
    INSTITUTE_OWNER = "institute_owner", "Institute owner"
    ADMIN = "admin", "Admin"


class User(AbstractUser):
    """Email is the login identifier; role drives authorization."""

    email = models.EmailField(unique=True)
    role = models.CharField(max_length=20, choices=Role.choices, default=Role.STUDENT)
    phone = models.CharField(max_length=32, blank=True)

    objects = UserManager()

    USERNAME_FIELD = "email"
    REQUIRED_FIELDS = ["username"]

    @property
    def is_trainer(self) -> bool:
        return self.role in {Role.TRAINER, Role.INSTITUTE_OWNER}

    def __str__(self) -> str:
        return f"{self.email} ({self.role})"
