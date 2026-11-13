from django.shortcuts import get_object_or_404
from rest_framework import generics, permissions, serializers, status
from rest_framework.exceptions import ValidationError
from rest_framework.response import Response
from rest_framework.views import APIView

from mechanics.geo import haversine_km
from mechanics.models import MechanicProfile
from mechanics.serializers import MechanicProfileSerializer


class NearbyMechanicsView(generics.ListAPIView):
    serializer_class = MechanicProfileSerializer
    permission_classes = [permissions.IsAuthenticated]
    search_fields = ["garage_name", "specialty", "area", "services"]

    def _query_float(self, name, *, minimum=None, maximum=None):
        value = self.request.query_params.get(name)
        if value is None:
            return None
        try:
            parsed = float(value)
        except (TypeError, ValueError) as exc:
            raise ValidationError({name: "Must be a valid number."}) from exc
        if minimum is not None and parsed < minimum or maximum is not None and parsed > maximum:
            raise ValidationError({name: "Value is outside the allowed range."})
        return parsed

    def _origin(self):
        lat = self.request.query_params.get("lat")
        lng = self.request.query_params.get("lng")
        if (lat is None) != (lng is None):
            raise ValidationError({"detail": "lat and lng must be provided together."})
        if lat is None:
            return None
        return (
            self._query_float("lat", minimum=-90, maximum=90),
            self._query_float("lng", minimum=-180, maximum=180),
        )

    def get_queryset(self):
        qs = MechanicProfile.objects.select_related("user").filter(is_verified=True)
        service = self.request.query_params.get("service")
        if service:
            qs = qs.filter(services__icontains=service)
        garage_type = self.request.query_params.get("garage_type")
        if garage_type in ("standard", "specialist"):
            qs = qs.filter(garage_type=garage_type)
            if garage_type == "specialist":
                qs = qs.filter(specialist_approved=True)
        if self.request.query_params.get("available") == "1":
            qs = qs.filter(is_available=True)
        if self.request.query_params.get("roadside") == "1":
            qs = qs.filter(roadside_supported=True)
        return qs

    def get_serializer_context(self):
        ctx = super().get_serializer_context()
        origin = self._origin()
        if origin:
            ctx["origin"] = origin
        return ctx

    def list(self, request, *args, **kwargs):
        queryset = self.filter_queryset(self.get_queryset())
        serializer = self.get_serializer(queryset, many=True)
        data = list(serializer.data)
        origin = self.get_serializer_context().get("origin")
        radius = request.query_params.get("radius_km")
        if radius is not None:
            try:
                radius = float(radius)
            except (TypeError, ValueError) as exc:
                raise ValidationError({"radius_km": "Must be a valid number."}) from exc
            if radius <= 0:
                raise ValidationError({"radius_km": "Must be greater than zero."})
            if origin is None:
                raise ValidationError({"detail": "radius_km requires lat and lng."})
        if origin:
            data.sort(key=lambda item: (item.get("distance_km") is None, item.get("distance_km") or 0, -item["rating_avg"]))
            if radius:
                data = [item for item in data if item.get("distance_km") is not None and item["distance_km"] <= radius]
        else:
            data.sort(key=lambda item: (-item["is_featured"], -item["rating_avg"]))
        return Response(data)


class MechanicDetailView(generics.RetrieveAPIView):
    queryset = MechanicProfile.objects.select_related("user")
    serializer_class = MechanicProfileSerializer
    permission_classes = [permissions.IsAuthenticated]


class MyMechanicProfileView(generics.RetrieveUpdateAPIView):
    serializer_class = MechanicProfileSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        profile, _ = MechanicProfile.objects.get_or_create(
            user=self.request.user,
            defaults={
                "garage_name": f"{self.request.user.full_name}'s garage",
                "services": ["general repair"],
            },
        )
        return profile


class AvailabilityView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        profile = MechanicProfile.objects.filter(user=request.user).first()
        if not profile:
            return Response({"detail": "Mechanic profile not found."}, status=status.HTTP_404_NOT_FOUND)
        if "is_available" in request.data:
            profile.is_available = serializers.BooleanField().to_internal_value(request.data["is_available"])
        if "latitude" in request.data:
            profile.latitude = serializers.FloatField(min_value=-90, max_value=90).to_internal_value(
                request.data["latitude"]
            )
        if "longitude" in request.data:
            profile.longitude = serializers.FloatField(min_value=-180, max_value=180).to_internal_value(
                request.data["longitude"]
            )
        profile.save()
        return Response(MechanicProfileSerializer(profile).data)


class DistancePreviewView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        lat = serializers.FloatField(min_value=-90, max_value=90).to_internal_value(
            request.query_params.get("lat")
        )
        lng = serializers.FloatField(min_value=-180, max_value=180).to_internal_value(
            request.query_params.get("lng")
        )
        mechanic_id = request.query_params.get("mechanic")
        mechanic = get_object_or_404(MechanicProfile, pk=mechanic_id)
        return Response({"distance_km": round(haversine_km(lat, lng, mechanic.latitude, mechanic.longitude), 2)})
