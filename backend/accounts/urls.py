from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView

from accounts.views import (
    DeviceTokenView,
    LoginView,
    MeView,
    OTPRequestView,
    OTPVerifyView,
    RegisterView,
)

urlpatterns = [
    path("register/", RegisterView.as_view()),
    path("login/", LoginView.as_view()),
    path("otp/request/", OTPRequestView.as_view()),
    path("otp/verify/", OTPVerifyView.as_view()),
    path("token/refresh/", TokenRefreshView.as_view()),
    path("me/", MeView.as_view()),
    path("device/", DeviceTokenView.as_view()),
]
