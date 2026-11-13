from django.urls import path

from mechanics.views import (
    AvailabilityView,
    DistancePreviewView,
    MechanicDetailView,
    MyMechanicProfileView,
    NearbyMechanicsView,
)

urlpatterns = [
    path("nearby/", NearbyMechanicsView.as_view()),
    path("me/", MyMechanicProfileView.as_view()),
    path("me/availability/", AvailabilityView.as_view()),
    path("distance/", DistancePreviewView.as_view()),
    path("<int:pk>/", MechanicDetailView.as_view()),
]
