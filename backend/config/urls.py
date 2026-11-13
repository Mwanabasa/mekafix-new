from django.contrib import admin
from django.urls import include, path

from config.views import health

admin.site.site_header = "MekaFix Admin"
admin.site.site_title = "MekaFix"
admin.site.index_title = "Verified mechanics, jobs and payments"

urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/health/", health),
    path("api/auth/", include("accounts.urls")),
    path("api/mechanics/", include("mechanics.urls")),
    path("api/jobs/", include("jobs.urls")),
    path("api/notifications/", include("notifications.urls")),
]
