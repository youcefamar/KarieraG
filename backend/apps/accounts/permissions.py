"""Simple role-based DRF permissions.

Keep this intentionally small; expand per-object rules in services/views later.
"""
from rest_framework.permissions import BasePermission

from .models import Role


class IsTrainerOrInstituteOwner(BasePermission):
    """Allow only users who can manage institutes/courses."""

    def has_permission(self, request, view):
        return bool(
            request.user
            and request.user.is_authenticated
            and request.user.role in {Role.TRAINER, Role.INSTITUTE_OWNER, Role.ADMIN}
        )


class IsStudent(BasePermission):
    def has_permission(self, request, view):
        return bool(
            request.user
            and request.user.is_authenticated
            and request.user.role == Role.STUDENT
        )
