from django.contrib import admin

from jobs.models import JobDecline, Payment, Rating, ServiceRecord, ServiceRecordShare, ServiceRequest, Vehicle


@admin.register(Vehicle)
class VehicleAdmin(admin.ModelAdmin):
    list_display = ("plate", "make", "model", "owner")


@admin.register(ServiceRequest)
class ServiceRequestAdmin(admin.ModelAdmin):
    list_display = ("id", "kind", "status", "customer", "mechanic", "created_at")
    list_filter = ("kind", "status")


@admin.register(Rating)
class RatingAdmin(admin.ModelAdmin):
    list_display = ("request", "stars", "created_at")


@admin.register(Payment)
class PaymentAdmin(admin.ModelAdmin):
    list_display = ("request", "amount", "status", "reference")

admin.site.register(ServiceRecord)
admin.site.register(ServiceRecordShare)
admin.site.register(JobDecline)
