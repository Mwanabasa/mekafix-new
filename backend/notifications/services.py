from django.conf import settings

from notifications.models import NotificationLog


def notify_user(user, title, body, channels=None):
    if not user:
        return []
    channels = channels or ["push"]
    logs = []
    for channel in channels:
        if channel == "sms" and not settings.SMS_FALLBACK_ENABLED:
            continue
        if channel == "push" and settings.FCM_ENABLED and user.fcm_token:
            # Real FCM would be invoked here. For the capstone we persist the payload.
            pass
        log = NotificationLog.objects.create(
            user=user,
            title=title,
            body=body,
            channel=channel,
            delivered=True,
        )
        logs.append(log)
    return logs
