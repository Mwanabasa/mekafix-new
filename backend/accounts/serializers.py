from django.conf import settings
from django.utils import timezone
from rest_framework import serializers
from rest_framework_simplejwt.tokens import RefreshToken

from accounts.models import PhoneOTP, User
from mechanics.models import MechanicProfile


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = (
            "id",
            "phone",
            "full_name",
            "role",
            "is_verified",
            "fcm_token",
            "last_latitude",
            "last_longitude",
        )
        read_only_fields = ("id", "phone", "is_verified")


class RegisterSerializer(serializers.Serializer):
    phone = serializers.CharField(max_length=20)
    full_name = serializers.CharField(max_length=120)
    password = serializers.CharField(min_length=4, write_only=True)
    role = serializers.ChoiceField(choices=User.Role.choices, default=User.Role.OWNER)
    garage_name = serializers.CharField(required=False, allow_blank=True)
    garage_type = serializers.ChoiceField(choices=[("standard", "Standard"), ("specialist", "Specialist")], required=False)
    supported_vehicle_types = serializers.ListField(child=serializers.CharField(), required=False)
    qualifications = serializers.CharField(required=False, allow_blank=True)
    services = serializers.ListField(child=serializers.CharField(), required=False)
    address = serializers.CharField(required=False, allow_blank=True)
    latitude = serializers.FloatField(required=False)
    longitude = serializers.FloatField(required=False)

    def validate_role(self, value):
        if value == User.Role.ADMIN:
            raise serializers.ValidationError("Administrator accounts cannot be registered publicly.")
        return value

    def validate_phone(self, value):
        phone = value.strip()
        if User.objects.filter(phone=phone).exists():
            raise serializers.ValidationError("This phone number is already registered.")
        return phone

    def create(self, validated_data):
        garage_name = validated_data.pop("garage_name", "")
        garage_type = validated_data.pop("garage_type", "standard")
        supported_vehicle_types = validated_data.pop("supported_vehicle_types", [])
        qualifications = validated_data.pop("qualifications", "")
        services = validated_data.pop("services", [])
        address = validated_data.pop("address", "")
        latitude = validated_data.pop("latitude", None)
        longitude = validated_data.pop("longitude", None)
        user = User.objects.create_user(
            phone=validated_data["phone"],
            password=validated_data["password"],
            full_name=validated_data["full_name"],
            role=validated_data["role"],
            is_verified=validated_data["role"] != User.Role.MECHANIC,
        )
        if user.role in (User.Role.MECHANIC, User.Role.DEALER):
            MechanicProfile.objects.create(
                user=user,
                garage_name=garage_name or f"{user.full_name}'s garage",
                services=services or ["general repair"],
                address=address or "Kampala",
                latitude=latitude if latitude is not None else 0.3476,
                longitude=longitude if longitude is not None else 32.5825,
                is_verified=False,
                garage_type=garage_type,
                supported_vehicle_types=supported_vehicle_types,
                qualifications=qualifications,
            )
        return user


class TokenResponseMixin:
    @staticmethod
    def tokens_for(user):
        refresh = RefreshToken.for_user(user)
        return {
            "access": str(refresh.access_token),
            "refresh": str(refresh),
            "user": UserSerializer(user).data,
        }


class LoginSerializer(serializers.Serializer, TokenResponseMixin):
    phone = serializers.CharField()
    password = serializers.CharField(write_only=True)

    def validate(self, attrs):
        try:
            user = User.objects.get(phone=attrs["phone"].strip())
        except User.DoesNotExist as exc:
            raise serializers.ValidationError("Invalid phone or password.") from exc
        if not user.check_password(attrs["password"]):
            raise serializers.ValidationError("Invalid phone or password.")
        attrs["user"] = user
        return attrs


class OTPRequestSerializer(serializers.Serializer):
    phone = serializers.CharField()

    def create(self, validated_data):
        otp = PhoneOTP.objects.create(
            phone=validated_data["phone"].strip(),
            code=settings.DEMO_OTP_CODE,
        )
        return otp


class OTPVerifySerializer(serializers.Serializer, TokenResponseMixin):
    phone = serializers.CharField()
    code = serializers.CharField()

    def validate(self, attrs):
        phone = attrs["phone"].strip()
        code = attrs["code"].strip()
        otp = PhoneOTP.objects.filter(phone=phone, consumed_at__isnull=True).order_by("-created_at").first()
        if not otp or not otp.is_valid(code):
            raise serializers.ValidationError("Invalid or expired OTP.")
        try:
            user = User.objects.get(phone=phone)
        except User.DoesNotExist as exc:
            raise serializers.ValidationError("No account exists for this phone number.") from exc
        otp.consumed_at = timezone.now()
        otp.save(update_fields=["consumed_at"])
        attrs["user"] = user
        return attrs
