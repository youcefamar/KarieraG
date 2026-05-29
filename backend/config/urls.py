"""Root URL configuration. All API routes live under /api/v1/."""
from django.contrib import admin
from django.urls import include, path
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

from config.views import health_check

api_v1 = [
    path("health/", health_check, name="health"),
    # Auth (JWT)
    path("auth/login/", TokenObtainPairView.as_view(), name="token_obtain_pair"),
    path("auth/refresh/", TokenRefreshView.as_view(), name="token_refresh"),
    path("auth/", include("apps.accounts.urls")),
    # Domain apps
    path("", include("apps.students.urls")),
    path("", include("apps.institutes.urls")),
    path("", include("apps.courses.urls")),
    path("", include("apps.enrollments.urls")),
    path("", include("apps.reviews.urls")),
    path("", include("apps.notifications.urls")),
    path("ai/", include("apps.ai.urls")),
    # OpenAPI schema + docs
    path("schema/", SpectacularAPIView.as_view(), name="schema"),
    path("docs/", SpectacularSwaggerView.as_view(url_name="schema"), name="docs"),
]

urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/v1/", include((api_v1, "v1"))),
]
