from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticatedOrReadOnly
from rest_framework.response import Response

from .models import Course, Favorite
from .serializers import CourseSerializer


class CourseViewSet(viewsets.ModelViewSet):
    """CRUD for /api/v1/courses/ plus favorite/similar actions.

    TODO(MVP1): object-level permission so only the owning institute can edit.
    """

    queryset = Course.objects.select_related("institute", "category").all()
    serializer_class = CourseSerializer
    permission_classes = [IsAuthenticatedOrReadOnly]

    @action(detail=True, methods=["post", "delete"])
    def favorite(self, request, pk=None):
        course = self.get_object()
        if request.method == "POST":
            Favorite.objects.get_or_create(user=request.user, course=course)
            return Response(status=status.HTTP_201_CREATED)
        Favorite.objects.filter(user=request.user, course=course).delete()
        return Response(status=status.HTTP_204_NO_CONTENT)

    @action(detail=True, methods=["get"])
    def similar(self, request, pk=None):
        # TODO(MVP2): back with ai.services.semantic_search over CourseEmbedding.
        return Response({"detail": "Not implemented", "results": []})
