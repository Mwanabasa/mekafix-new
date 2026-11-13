from django.contrib import admin

from mechanics.models import MechanicProfile


@admin.register(MechanicProfile)
class MechanicProfileAdmin(admin.ModelAdmin):
    list_display = (
        "garage_name",
        "area",
        "is_verified",
        "garage_type",
        "specialist_approved",
        "is_available",
        "rating_avg",
        "price_min",
        "price_max",
    )
    list_filter = ("is_verified", "is_available", "garage_type", "specialist_approved", "area")
    search_fields = ("garage_name", "specialty", "user__phone")
