from rest_framework import generics, status
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from accounts.models import User
from accounts.serializers import (
    LoginSerializer,
    OTPRequestSerializer,
    OTPVerifySerializer,
    RegisterSerializer,
    UserSerializer,
)
from notifications.services import notify_user


class RegisterView(generics.CreateAPIView):
    permission_classes = [AllowAny]
    serializer_class = RegisterSerializer

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        notify_user(
            user,
            title="Welcome to MekaFix",
            body="Your account is ready. Search nearby verified mechanics or wait for admin verification.",
            channels=["sms"],
        )
        return Response(LoginSerializer.tokens_for(user), status=status.HTTP_201_CREATED)


class LoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        return Response(LoginSerializer.tokens_for(serializer.validated_data["user"]))


class OTPRequestView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = OTPRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        otp = serializer.save()
        return Response(
            {
                "detail": "OTP sent via SMS fallback (demo code 123456).",
                "phone": otp.phone,
            }
        )


class OTPVerifyView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = OTPVerifySerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        return Response(OTPVerifySerializer.tokens_for(serializer.validated_data["user"]))


class MeView(generics.RetrieveUpdateAPIView):
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]

    def get_object(self):
        return self.request.user


class DeviceTokenView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        token = request.data.get("fcm_token", "")
        lat = request.data.get("latitude")
        lng = request.data.get("longitude")
        user: User = request.user
        if token:
            user.fcm_token = token
        if lat is not None:
            user.last_latitude = lat
        if lng is not None:
            user.last_longitude = lng
        user.save()
        return Response(UserSerializer(user).data)
