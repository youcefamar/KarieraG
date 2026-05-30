"""Project-level views (health check)."""
from django.db import connection
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework import status


@api_view(["GET"])
@permission_classes([AllowAny])
def health_check(request):
    try:
        connection.ensure_connection()
    except Exception:
        return Response({"status": "error", "db": "unreachable"}, status=status.HTTP_503_SERVICE_UNAVAILABLE)
    return Response({"status": "ok"})
