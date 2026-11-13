from django.db.models import Avg
from django.db.models import Q
from django.shortcuts import get_object_or_404
from django.utils import timezone
from rest_framework import generics, permissions, status
from rest_framework.exceptions import ValidationError
from rest_framework.response import Response
from rest_framework.views import APIView

from jobs.models import JobDecline, Payment, Rating, ServiceRecord, ServiceRecordShare, ServiceRequest, Vehicle
from jobs.serializers import (
    PaymentSerializer,
    RatingSerializer,
    ServiceRequestSerializer,
    VehicleSerializer,
    ServiceRecordSerializer,
)
from mechanics.models import MechanicProfile
from notifications.services import notify_user


class VehicleListCreateView(generics.ListCreateAPIView):
    serializer_class = VehicleSerializer

    def get_queryset(self):
        return Vehicle.objects.filter(owner=self.request.user)


class ServiceRequestListCreateView(generics.ListCreateAPIView):
    serializer_class = ServiceRequestSerializer

    def get_queryset(self):
        user = self.request.user
        qs = ServiceRequest.objects.select_related("mechanic", "vehicle", "customer", "rating", "payment")
        if user.role == "mechanic":
            profile = MechanicProfile.objects.filter(user=user).first()
            if not profile or not profile.is_verified or not profile.is_available:
                return qs.none()
            return qs.filter(Q(mechanic=profile) | Q(status=ServiceRequest.Status.PENDING, mechanic__isnull=True)).exclude(declines__mechanic=profile).distinct()
        if user.role == "admin":
            return qs.all()
        return qs.filter(customer=user)

    def perform_create(self, serializer):
        job = serializer.save()
        if job.mechanic:
            notify_user(
                job.mechanic.user,
                title="New MekaFix request",
                body=f"{job.customer.full_name} needs {job.get_kind_display()}.",
                channels=["push", "sms"],
            )


class ServiceRequestDetailView(generics.RetrieveAPIView):
    serializer_class = ServiceRequestSerializer

    def get_queryset(self):
        user = self.request.user
        queryset = ServiceRequest.objects.select_related("mechanic", "vehicle", "customer")
        if user.role == "admin":
            return queryset
        return queryset.filter(Q(customer=user) | Q(mechanic__user=user))


class AcceptJobView(APIView):
    def post(self, request, pk):
        job = get_object_or_404(ServiceRequest.objects.select_related("mechanic", "customer"), pk=pk)
        profile = MechanicProfile.objects.filter(user=request.user).first()
        if not profile or not profile.is_verified:
            return Response({"detail": "Only verified mechanics can accept jobs."}, status=status.HTTP_403_FORBIDDEN)
        if not profile.is_available:
            return Response({"detail": "Set your business to available before accepting jobs."}, status=status.HTTP_400_BAD_REQUEST)
        if job.status != ServiceRequest.Status.PENDING:
            return Response({"detail": "Only pending jobs can be accepted."}, status=status.HTTP_400_BAD_REQUEST)
        if job.declines.filter(mechanic=profile).exists():
            return Response({"detail": "You previously declined this request."}, status=status.HTTP_403_FORBIDDEN)
        if job.mechanic and job.mechanic != profile:
            return Response({"detail": "This job is assigned to another mechanic."}, status=status.HTTP_403_FORBIDDEN)
        job.mechanic = profile
        job.status = ServiceRequest.Status.ACCEPTED
        if not job.quoted_amount:
            job.quoted_amount = profile.price_min
        job.save()
        notify_user(
            job.customer,
            title="Request accepted",
            body=f"{profile.garage_name} accepted your {job.get_kind_display().lower()}. Tap to call {profile.user.phone}.",
            channels=["push", "sms"],
        )
        return Response(ServiceRequestSerializer(job, context={"request": request}).data)


class RejectJobView(APIView):
    def post(self, request, pk):
        job = get_object_or_404(ServiceRequest, pk=pk, status=ServiceRequest.Status.PENDING)
        profile = MechanicProfile.objects.filter(user=request.user).first()
        if not profile:
            return Response({"detail": "Only mechanics can decline jobs."}, status=status.HTTP_403_FORBIDDEN)
        if job.mechanic and job.mechanic != profile:
            return Response({"detail": "This request belongs to another mechanic."}, status=status.HTTP_403_FORBIDDEN)
        JobDecline.objects.get_or_create(request=job, mechanic=profile)
        if job.mechanic_id == profile.id:
            job.mechanic = None
        job.save(update_fields=["mechanic", "updated_at"])
        return Response({"detail": "Request declined. It is available to other eligible mechanics."})


class ReassignJobView(APIView):
    def post(self, request, pk):
        job = get_object_or_404(ServiceRequest.objects.select_related("mechanic", "customer"), pk=pk, customer=request.user)
        if job.status != ServiceRequest.Status.PENDING:
            return Response({"detail": "Only unanswered pending requests can be reassigned."}, status=status.HTTP_400_BAD_REQUEST)
        if job.mechanic_id:
            old_profile = job.mechanic
            old_mechanic = old_profile.user
            JobDecline.objects.get_or_create(request=job, mechanic=old_profile)
            job.mechanic = None
            job.save(update_fields=["mechanic", "updated_at"])
            notify_user(old_mechanic, title="Request reassigned", body=f"The driver has moved request #{job.pk} to another mechanic.", channels=["push"])
        return Response(ServiceRequestSerializer(job, context={"request": request}).data)


class ServiceRecordListCreateView(generics.ListCreateAPIView):
    serializer_class = ServiceRecordSerializer

    def get_queryset(self):
        user = self.request.user
        qs = ServiceRecord.objects.select_related("vehicle", "mechanic", "service_request")
        if user.role == "mechanic":
            return qs.filter(Q(mechanic__user=user) | Q(shares__mechanic__user=user)).distinct()
        return qs.filter(vehicle__owner=user, shared_with_owner=True)

    def perform_create(self, serializer):
        user = self.request.user
        if user.role != "mechanic":
            raise ValidationError("Only mechanics can create service records.")
        request_id = self.request.data.get("service_request")
        job = get_object_or_404(ServiceRequest, pk=request_id, mechanic__user=user, status=ServiceRequest.Status.COMPLETED)
        vehicle = job.vehicle
        if vehicle is None:
            raise ValidationError("The completed job must be linked to a vehicle before recording service notes.")
        serializer.save(vehicle=vehicle, service_request=job)


class ShareServiceRecordView(APIView):
    def post(self, request, pk):
        record = get_object_or_404(ServiceRecord, pk=pk, vehicle__owner=request.user)
        mechanic_id = request.data.get("mechanic_profile_id")
        profile = get_object_or_404(MechanicProfile, pk=mechanic_id, is_verified=True)
        ServiceRecordShare.objects.get_or_create(record=record, mechanic=profile, defaults={"shared_by": request.user})
        return Response({"detail": f"Service record shared with {profile.garage_name}."})


class UpdateStatusView(APIView):
    def post(self, request, pk):
        job = get_object_or_404(ServiceRequest.objects.select_related("mechanic", "customer"), pk=pk)
        new_status = request.data.get("status")
        allowed = {choice for choice, _ in ServiceRequest.Status.choices}
        if new_status not in allowed:
            return Response({"detail": "Invalid status."}, status=status.HTTP_400_BAD_REQUEST)
        transitions = {
            ServiceRequest.Status.PENDING: {ServiceRequest.Status.ACCEPTED, ServiceRequest.Status.CANCELLED},
            ServiceRequest.Status.ACCEPTED: {
                ServiceRequest.Status.EN_ROUTE,
                ServiceRequest.Status.IN_PROGRESS,
                ServiceRequest.Status.COMPLETED,
                ServiceRequest.Status.CANCELLED,
            },
            ServiceRequest.Status.EN_ROUTE: {ServiceRequest.Status.IN_PROGRESS, ServiceRequest.Status.CANCELLED},
            ServiceRequest.Status.IN_PROGRESS: {ServiceRequest.Status.COMPLETED, ServiceRequest.Status.CANCELLED},
            ServiceRequest.Status.COMPLETED: set(),
            ServiceRequest.Status.CANCELLED: set(),
        }
        if request.user.role != "admin" and new_status not in transitions[job.status]:
            return Response({"detail": "Invalid status transition."}, status=status.HTTP_400_BAD_REQUEST)
        if request.user.role != "admin" and request.user == job.customer and new_status != ServiceRequest.Status.CANCELLED:
            return Response({"detail": "Customers can only cancel requests."}, status=status.HTTP_403_FORBIDDEN)
        if request.user not in (job.customer, getattr(job.mechanic, "user", None)) and request.user.role != "admin":
            return Response({"detail": "Not allowed."}, status=status.HTTP_403_FORBIDDEN)
        job.status = new_status
        if "quoted_amount" in request.data:
            job.quoted_amount = request.data["quoted_amount"]
        job.save()
        target = job.customer if request.user != job.customer else getattr(job.mechanic, "user", None)
        notify_user(
            target,
            title="Job update",
            body=f"Request #{job.pk} is now {job.get_status_display().lower()}.",
            channels=["push", "sms"] if new_status in ("accepted", "completed") else ["push"],
        )
        return Response(ServiceRequestSerializer(job, context={"request": request}).data)


class RateJobView(APIView):
    def post(self, request, pk):
        job = ServiceRequest.objects.select_related("mechanic").get(pk=pk)
        if job.customer != request.user:
            return Response({"detail": "Only the customer can rate this job."}, status=status.HTTP_403_FORBIDDEN)
        if job.status != ServiceRequest.Status.COMPLETED:
            return Response({"detail": "Rate after the job is completed."}, status=status.HTTP_400_BAD_REQUEST)
        serializer = RatingSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        rating, _ = Rating.objects.update_or_create(request=job, defaults=serializer.validated_data)
        if job.mechanic:
            stats = Rating.objects.filter(request__mechanic=job.mechanic).aggregate(avg=Avg("stars"))
            job.mechanic.rating_avg = round(stats["avg"] or 0, 2)
            job.mechanic.rating_count = Rating.objects.filter(request__mechanic=job.mechanic).count()
            job.mechanic.save(update_fields=["rating_avg", "rating_count"])
        return Response(RatingSerializer(rating).data)


class PayJobView(APIView):
    def post(self, request, pk):
        job = ServiceRequest.objects.get(pk=pk)
        if job.customer != request.user:
            return Response({"detail": "Only the customer can pay."}, status=status.HTTP_403_FORBIDDEN)
        amount = int(request.data.get("amount") or job.quoted_amount or 0)
        payment, _ = Payment.objects.update_or_create(
            request=job,
            defaults={
                "amount": amount,
                "method": request.data.get("method", "momo"),
                "momo_phone": request.data.get("momo_phone", request.user.phone),
                "status": Payment.Status.CONFIRMED,
                "reference": f"MOMO-SANDBOX-{job.pk}-{timezone.now().strftime('%H%M%S')}",
                "confirmed_at": timezone.now(),
            },
        )
        notify_user(
            job.mechanic.user if job.mechanic else job.customer,
            title="Payment marked as paid",
            body=f"UGX {amount:,} confirmed on the MekaFix mobile-money sandbox.",
            channels=["push"],
        )
        return Response(PaymentSerializer(payment).data)


class VehicleHistoryView(APIView):
    def get(self, request, pk):
        vehicle = Vehicle.objects.get(pk=pk, owner=request.user)
        jobs = ServiceRequest.objects.filter(vehicle=vehicle).order_by("-created_at")
        return Response(
            {
                "vehicle": VehicleSerializer(vehicle).data,
                "history": ServiceRequestSerializer(jobs, many=True, context={"request": request}).data,
            }
        )
