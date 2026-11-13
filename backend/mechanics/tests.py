from rest_framework.test import APITestCase

from accounts.models import User
from mechanics.models import MechanicProfile


class MechanicsApiTests(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            phone="256733333333",
            password="pass123",
            full_name="Owner",
            role=User.Role.OWNER,
            is_verified=True,
        )
        self.client.force_authenticate(self.user)
        self.mechanic = User.objects.create_user(
            phone="256744444444",
            password="pass123",
            full_name="Mechanic",
            role=User.Role.MECHANIC,
            is_verified=True,
        )
        MechanicProfile.objects.create(
            user=self.mechanic,
            garage_name="Test Garage",
            is_verified=True,
        )

    def test_nearby_rejects_invalid_coordinates(self):
        response = self.client.get("/api/mechanics/nearby/", {"lat": "not-a-number", "lng": "32.5"})

        self.assertEqual(response.status_code, 400)
        self.assertIn("lat", response.data)

    def test_availability_parses_boolean_values(self):
        profile = MechanicProfile.objects.get(garage_name="Test Garage")
        self.client.force_authenticate(self.mechanic)
        response = self.client.post("/api/mechanics/me/availability/", {"is_available": "false"}, format="json")

        self.assertEqual(response.status_code, 200)
        profile.refresh_from_db()
        self.assertFalse(profile.is_available)
