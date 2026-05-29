from django.urls import path

from .views import (
    CourseAdvisorView,
    CourseMatchView,
    CourseQualityCheckView,
    RoadmapView,
    SemanticSearchView,
)

urlpatterns = [
    path("course-advisor/", CourseAdvisorView.as_view(), name="ai-course-advisor"),
    path("semantic-search/", SemanticSearchView.as_view(), name="ai-semantic-search"),
    path("course-match/", CourseMatchView.as_view(), name="ai-course-match"),
    path("roadmap/", RoadmapView.as_view(), name="ai-roadmap"),
    path("course-quality-check/", CourseQualityCheckView.as_view(), name="ai-course-quality-check"),
]
