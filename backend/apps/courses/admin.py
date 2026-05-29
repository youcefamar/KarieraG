from django.contrib import admin

from .models import Course, CourseCategory, CourseSession, Favorite


@admin.register(Course)
class CourseAdmin(admin.ModelAdmin):
    list_display = ("title", "institute", "category", "mode", "status", "is_featured")
    list_filter = ("mode", "status", "is_featured", "category")
    search_fields = ("title", "about")


admin.site.register(CourseCategory)
admin.site.register(CourseSession)
admin.site.register(Favorite)
