import pytest
from django.urls import reverse


@pytest.mark.django_db
def test_health_check(api_client):
    resp = api_client.get(reverse("v1:health"))
    assert resp.status_code == 200
    assert resp.json() == {"status": "ok"}
