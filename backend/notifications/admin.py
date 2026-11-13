from django.contrib import admin

from notifications.models import NotificationLog


@admin.register(NotificationLog)
class NotificationLogAdmin(admin.ModelAdmin):
    list_display = ("user", "channel", "title", "created_at")
    list_filter = ("channel",)
