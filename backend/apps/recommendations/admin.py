from django.contrib import admin

from .models import AIRecommendationLog, SearchLog

admin.site.register(AIRecommendationLog)
admin.site.register(SearchLog)
