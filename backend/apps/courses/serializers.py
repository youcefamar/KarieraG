from rest_framework import serializers

from .models import Course, CourseCategory


class CourseCategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = CourseCategory
        fields = ["id", "name", "slug"]


class CourseSerializer(serializers.ModelSerializer):
    class Meta:
        model = Course
        fields = [
            "id", "institute", "category", "title", "about", "program",
            "prerequisites", "price_dzd", "duration", "location", "mode",
            "status", "image_url", "is_featured", "created_at", "updated_at",
        ]
        read_only_fields = ["id", "is_featured", "created_at", "updated_at"]
