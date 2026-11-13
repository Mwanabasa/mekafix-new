from django.contrib import admin

from accounts.models import PhoneOTP, User


@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    list_display = ("phone", "full_name", "role", "is_verified", "is_staff")
    search_fields = ("phone", "full_name")
    list_filter = ("role", "is_verified")


@admin.register(PhoneOTP)
class PhoneOTPAdmin(admin.ModelAdmin):
    list_display = ("phone", "code", "created_at", "consumed_at")
