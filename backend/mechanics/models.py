from django.conf import settings
from django.db import models


class MechanicProfile(models.Model):
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="mechanic_profile"
    )
    garage_name = models.CharField(max_length=160)
    specialty = models.CharField(max_length=120, default="General mechanic")
    services = models.JSONField(default=list)
    address = models.CharField(max_length=255, blank=True)
    area = models.CharField(max_length=80, default="Kampala")
    latitude = models.FloatField(default=0.3476)
    longitude = models.FloatField(default=32.5825)
    price_min = models.PositiveIntegerField(default=30000, help_text="UGX")
    price_max = models.PositiveIntegerField(default=150000, help_text="UGX")
    rating_avg = models.FloatField(default=0)
    rating_count = models.PositiveIntegerField(default=0)
    is_available = models.BooleanField(default=True)
    is_verified = models.BooleanField(default=False)
    is_featured = models.BooleanField(default=False)
    bio = models.TextField(blank=True)
    roadside_supported = models.BooleanField(default=True)

    def __str__(self):
        return self.garage_name
