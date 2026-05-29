import pytest

from apps.accounts.models import Role, User
from apps.courses.models import Course, CourseCategory
from apps.institutes.models import Institute


@pytest.mark.django_db
def test_create_user_defaults_to_student():
    user = User.objects.create_user(email="s@example.com", username="s", password="pw12345678")
    assert user.role == Role.STUDENT
    assert user.is_trainer is False


@pytest.mark.django_db
def test_create_trainer_and_course():
    owner = User.objects.create_user(
        email="t@example.com", username="t", password="pw12345678", role=Role.INSTITUTE_OWNER
    )
    assert owner.is_trainer is True
    institute = Institute.objects.create(owner=owner, name="BrainerX")
    category = CourseCategory.objects.create(name="Development", slug="development")
    course = Course.objects.create(institute=institute, category=category, title="Python 101")
    assert course.status == Course.Status.OPEN
    assert course.institute.name == "BrainerX"
