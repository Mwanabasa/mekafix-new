from django.conf import settings
from django.db import models


class Vehicle(models.Model):
    owner = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="vehicles"
    )
    plate = models.CharField(max_length=20)
    make = models.CharField(max_length=80)
    model = models.CharField(max_length=80)
    year = models.PositiveIntegerField(null=True, blank=True)
    notes = models.TextField(blank=True)

    class Meta:
        unique_together = ("owner", "plate")

    def __str__(self):
        return f"{self.plate} {self.make} {self.model}"


class ServiceRequest(models.Model):
    class Kind(models.TextChoices):
        ROADSIDE = "roadside", "Roadside assistance"
        BOOKING = "booking", "Appointment booking"

    class Status(models.TextChoices):
        PENDING = "pending", "Pending"
        ACCEPTED = "accepted", "Accepted"
        EN_ROUTE = "en_route", "En route"
        IN_PROGRESS = "in_progress", "In progress"
        COMPLETED = "completed", "Completed"
        CANCELLED = "cancelled", "Cancelled"

    customer = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="service_requests"
    )
    mechanic = models.ForeignKey(
        "mechanics.MechanicProfile",
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="jobs",
    )
    vehicle = models.ForeignKey(Vehicle, on_delete=models.SET_NULL, null=True, blank=True)
    kind = models.CharField(max_length=20, choices=Kind.choices)
    status = models.CharField(max_length=20, choices=Status.choices, default=Status.PENDING)
    description = models.TextField()
    latitude = models.FloatField()
    longitude = models.FloatField()
    address = models.CharField(max_length=255, blank=True)
    scheduled_at = models.DateTimeField(null=True, blank=True)
    quoted_amount = models.PositiveIntegerField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.kind} #{self.pk} ({self.status})"


class Rating(models.Model):
    request = models.OneToOneField(ServiceRequest, on_delete=models.CASCADE, related_name="rating")
    stars = models.PositiveSmallIntegerField()
    comment = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)


class Payment(models.Model):
    class Status(models.TextChoices):
        PENDING = "pending", "Pending"
        CONFIRMED = "confirmed", "Confirmed"
        FAILED = "failed", "Failed"

    request = models.OneToOneField(ServiceRequest, on_delete=models.CASCADE, related_name="payment")
    amount = models.PositiveIntegerField()
    method = models.CharField(max_length=20, default="momo")
    momo_phone = models.CharField(max_length=20, blank=True)
    status = models.CharField(max_length=20, choices=Status.choices, default=Status.PENDING)
    reference = models.CharField(max_length=64, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    confirmed_at = models.DateTimeField(null=True, blank=True)


class ServiceRecord(models.Model):
    vehicle = models.ForeignKey(Vehicle, on_delete=models.CASCADE, related_name="service_records")
    mechanic = models.ForeignKey("mechanics.MechanicProfile", on_delete=models.SET_NULL, null=True, blank=True, related_name="service_records")
    service_request = models.ForeignKey(ServiceRequest, on_delete=models.SET_NULL, null=True, blank=True, related_name="service_records")
    title = models.CharField(max_length=160)
    odometer_km = models.PositiveIntegerField(null=True, blank=True)
    diagnosis = models.TextField(blank=True)
    work_done = models.TextField()
    parts_used = models.TextField(blank=True)
    recommendations = models.TextField(blank=True)
    shared_with_owner = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-created_at"]

    def __str__(self):
        return f"{self.vehicle.plate}: {self.title}"


class JobDecline(models.Model):
    request = models.ForeignKey(ServiceRequest, on_delete=models.CASCADE, related_name="declines")
    mechanic = models.ForeignKey("mechanics.MechanicProfile", on_delete=models.CASCADE, related_name="declined_jobs")
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ("request", "mechanic")

    def __str__(self):
        return f"Mechanic {self.mechanic_id} declined request {self.request_id}"


class ServiceRecordShare(models.Model):
    record = models.ForeignKey(ServiceRecord, on_delete=models.CASCADE, related_name="shares")
    mechanic = models.ForeignKey("mechanics.MechanicProfile", on_delete=models.CASCADE, related_name="shared_service_records")
    shared_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="service_record_shares")
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ("record", "mechanic")

    def __str__(self):
        return f"Record {self.record_id} shared with mechanic {self.mechanic_id}"
