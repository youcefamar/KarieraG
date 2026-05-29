"""AI endpoints. Mocked responses with clear TODOs; logic lives in services/.

All endpoints are grounded-RAG by design (see prompts/GUARDRAILS.md). For now
they return deterministic mock payloads so the API contract is stable.
"""
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView


class CourseAdvisorView(APIView):
    """POST /api/v1/ai/course-advisor/"""

    permission_classes = [IsAuthenticated]

    def post(self, request):
        goal = request.data.get("goal", "")
        # TODO: recommend_courses(goal=goal) -> assemble course_advisor prompt -> LLM.
        return Response({"goal": goal, "recommendations": [], "mocked": True})


class SemanticSearchView(APIView):
    """GET /api/v1/ai/semantic-search/?q=..."""

    permission_classes = [IsAuthenticated]

    def get(self, request):
        query = request.query_params.get("q", "")
        # TODO: return services.search.semantic_search(query) results.
        return Response({"query": query, "results": [], "mocked": True})


class CourseMatchView(APIView):
    """POST /api/v1/ai/course-match/"""

    permission_classes = [IsAuthenticated]

    def post(self, request):
        # TODO: compute cosine similarity between student goal and course embedding.
        return Response({"score": None, "mocked": True})


class RoadmapView(APIView):
    """POST /api/v1/ai/roadmap/"""

    permission_classes = [IsAuthenticated]

    def post(self, request):
        goal = request.data.get("goal", "")
        # TODO: retrieve courses -> assemble roadmap prompt -> LLM -> ordered steps.
        return Response({"goal": goal, "steps": [], "mocked": True})


class CourseQualityCheckView(APIView):
    """POST /api/v1/ai/course-quality-check/"""

    permission_classes = [IsAuthenticated]

    def post(self, request):
        # TODO: assemble course_quality prompt over request course -> LLM.
        return Response({"quality_score": None, "issues": [], "mocked": True})
