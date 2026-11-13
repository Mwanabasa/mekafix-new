from django.urls import path

from jobs.views import (
    AcceptJobView,
    PayJobView,
    RateJobView,
    RejectJobView,
    ReassignJobView,
    ServiceRecordListCreateView,
    ShareServiceRecordView,
    ServiceRequestDetailView,
    ServiceRequestListCreateView,
    UpdateStatusView,
    VehicleHistoryView,
    VehicleListCreateView,
)

urlpatterns = [
    path("vehicles/", VehicleListCreateView.as_view()),
    path("service-records/", ServiceRecordListCreateView.as_view()),
    path("service-records/<int:pk>/share/", ShareServiceRecordView.as_view()),
    path("vehicles/<int:pk>/history/", VehicleHistoryView.as_view()),
    path("requests/", ServiceRequestListCreateView.as_view()),
    path("requests/<int:pk>/", ServiceRequestDetailView.as_view()),
    path("requests/<int:pk>/accept/", AcceptJobView.as_view()),
    path("requests/<int:pk>/reject/", RejectJobView.as_view()),
    path("requests/<int:pk>/reassign/", ReassignJobView.as_view()),
    path("requests/<int:pk>/status/", UpdateStatusView.as_view()),
    path("requests/<int:pk>/rate/", RateJobView.as_view()),
    path("requests/<int:pk>/pay/", PayJobView.as_view()),
]
