from rest_framework import generics, serializers

from notifications.models import NotificationLog


class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = NotificationLog
        fields = ("id", "title", "body", "channel", "delivered", "created_at")


class NotificationListView(generics.ListAPIView):
    serializer_class = NotificationSerializer

    def get_queryset(self):
        return NotificationLog.objects.filter(user=self.request.user)
