"""Accounts business logic. Views stay thin; logic lives here."""
from .models import User


def register_user(*, email: str, username: str, password: str, role: str, phone: str = "") -> User:
    """Create a user and their matching profile.

    TODO: create StudentProfile/TrainerProfile based on role (Phase 2b+).
    """
    return User.objects.create_user(
        email=email, username=username, password=password, role=role, phone=phone
    )
