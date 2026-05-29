"""Project-level views (health check)."""
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response


@api_view(["GET"])
@permission_classes([AllowAny])
def health_check(request):
    """Liveness probe. TODO: add DB/Redis checks when needed."""
    return Response({"status": "ok"})
