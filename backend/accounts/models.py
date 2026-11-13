from datetime import timedelta

from django.contrib.auth.base_user import BaseUserManager
from django.contrib.auth.models import AbstractUser
from django.db import models
from django.utils import timezone


class UserManager(BaseUserManager):
    use_in_migrations = True

    def _create_user(self, phone, password, **extra_fields):
        if not phone:
            raise ValueError("A phone number is required")
        phone = str(phone).strip()
        user = self.model(phone=phone, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_user(self, phone, password=None, **extra_fields):
        extra_fields.setdefault("is_staff", False)
        extra_fields.setdefault("is_superuser", False)
        return self._create_user(phone, password, **extra_fields)

    def create_superuser(self, phone, password=None, **extra_fields):
        extra_fields.setdefault("is_staff", True)
        extra_fields.setdefault("is_superuser", True)
        extra_fields.setdefault("role", User.Role.ADMIN)
        extra_fields.setdefault("is_verified", True)
        return self._create_user(phone, password, **extra_fields)


class User(AbstractUser):
    class Role(models.TextChoices):
        OWNER = "owner", "Vehicle owner"
        MECHANIC = "mechanic", "Mechanic"
        DEALER = "dealer", "Spare-parts dealer"
        ADMIN = "admin", "Administrator"

    username = None
    email = models.EmailField(blank=True)
    phone = models.CharField(max_length=20, unique=True)
    full_name = models.CharField(max_length=120)
    role = models.CharField(max_length=20, choices=Role.choices, default=Role.OWNER)
    is_verified = models.BooleanField(default=False)
    fcm_token = models.CharField(max_length=255, blank=True)
    last_latitude = models.FloatField(null=True, blank=True)
    last_longitude = models.FloatField(null=True, blank=True)

    USERNAME_FIELD = "phone"
    REQUIRED_FIELDS = ["full_name"]

    objects = UserManager()

    def __str__(self):
        return f"{self.full_name} ({self.phone})"


class PhoneOTP(models.Model):
    phone = models.CharField(max_length=20, db_index=True)
    code = models.CharField(max_length=6)
    created_at = models.DateTimeField(auto_now_add=True)
    consumed_at = models.DateTimeField(null=True, blank=True)

    def is_valid(self, code):
        if self.consumed_at:
            return False
        if timezone.now() - self.created_at > timedelta(minutes=10):
            return False
        return self.code == str(code)
