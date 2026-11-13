from rest_framework import serializers

from jobs.models import Payment, Rating, ServiceRecord, ServiceRequest, Vehicle
from mechanics.serializers import MechanicProfileSerializer


class VehicleSerializer(serializers.ModelSerializer):
    class Meta:
        model = Vehicle
        fields = ("id", "plate", "make", "model", "year", "notes")
        extra_kwargs = {"notes": {"required": False, "allow_blank": True}}

    def create(self, validated_data):
        validated_data["owner"] = self.context["request"].user
        return super().create(validated_data)


class RatingSerializer(serializers.ModelSerializer):
    class Meta:
        model = Rating
        fields = ("stars", "comment", "created_at")
        read_only_fields = ("created_at",)


class PaymentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Payment
        fields = ("amount", "method", "momo_phone", "status", "reference", "created_at", "confirmed_at")
        read_only_fields = ("status", "reference", "created_at", "confirmed_at")


class ServiceRequestSerializer(serializers.ModelSerializer):
    mechanic_detail = MechanicProfileSerializer(source="mechanic", read_only=True)
    vehicle_detail = VehicleSerializer(source="vehicle", read_only=True)
    rating = RatingSerializer(read_only=True)
    payment = PaymentSerializer(read_only=True)
    customer_name = serializers.CharField(source="customer.full_name", read_only=True)
    customer_phone = serializers.CharField(source="customer.phone", read_only=True)

    class Meta:
        model = ServiceRequest
        fields = (
            "id",
            "kind",
            "status",
            "description",
            "latitude",
            "longitude",
            "address",
            "scheduled_at",
            "quoted_amount",
            "mechanic",
            "mechanic_detail",
            "vehicle",
            "vehicle_detail",
            "rating",
            "payment",
            "customer_name",
            "customer_phone",
            "created_at",
            "updated_at",
        )
        read_only_fields = ("status", "created_at", "updated_at")

    def create(self, validated_data):
        validated_data["customer"] = self.context["request"].user
        if not validated_data.get("quoted_amount") and validated_data.get("mechanic"):
            mechanic = validated_data["mechanic"]
            validated_data["quoted_amount"] = mechanic.price_min
        return super().create(validated_data)


class ServiceRecordSerializer(serializers.ModelSerializer):
    vehicle_label = serializers.SerializerMethodField()
    mechanic_name = serializers.CharField(source="mechanic.garage_name", read_only=True)

    class Meta:
        model = ServiceRecord
        fields = ("id", "vehicle", "vehicle_label", "mechanic", "mechanic_name", "service_request", "title", "odometer_km", "diagnosis", "work_done", "parts_used", "recommendations", "shared_with_owner", "created_at")
        read_only_fields = ("id", "vehicle", "mechanic", "service_request", "created_at", "vehicle_label", "mechanic_name")

    def get_vehicle_label(self, obj):
        return f"{obj.vehicle.plate} · {obj.vehicle.make} {obj.vehicle.model}"

    def create(self, validated_data):
        request = self.context["request"]
        if request.user.role == "mechanic":
            from mechanics.models import MechanicProfile
            validated_data["mechanic"] = MechanicProfile.objects.filter(user=request.user).first()
        return super().create(validated_data)
