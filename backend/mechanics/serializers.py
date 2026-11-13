from rest_framework import serializers

from accounts.serializers import UserSerializer
from mechanics.geo import haversine_km
from mechanics.models import MechanicProfile


class MechanicProfileSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    distance_km = serializers.SerializerMethodField()

    class Meta:
        model = MechanicProfile
        fields = (
            "id",
            "user",
            "garage_name",
            "specialty",
            "services",
            "address",
            "area",
            "latitude",
            "longitude",
            "price_min",
            "price_max",
            "rating_avg",
            "rating_count",
            "is_available",
            "is_verified",
            "is_featured",
            "bio",
            "roadside_supported",
            "garage_type",
            "supported_vehicle_types",
            "qualifications",
            "specialist_approved",
            "business_hours",
            "business_description",
            "distance_km",
        )
        read_only_fields = ("rating_avg", "rating_count", "is_verified", "is_featured", "specialist_approved")

    def get_distance_km(self, obj):
        origin = self.context.get("origin")
        if not origin:
            return None
        return round(haversine_km(origin[0], origin[1], obj.latitude, obj.longitude), 2)
