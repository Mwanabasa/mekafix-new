from django.conf import settings
from django.db import models


class NotificationLog(models.Model):
    class Channel(models.TextChoices):
        PUSH = "push", "Push"
        SMS = "sms", "SMS"

    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="notifications")
    title = models.CharField(max_length=160)
    body = models.TextField()
    channel = models.CharField(max_length=10, choices=Channel.choices)
    delivered = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-created_at"]
