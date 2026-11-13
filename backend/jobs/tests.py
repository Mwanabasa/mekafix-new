from rest_framework.test import APITestCase

from accounts.models import User
from mechanics.models import MechanicProfile


class MekaFixApiTests(APITestCase):
    def setUp(self):
        self.owner = User.objects.create_user(
            phone="256711111111",
            password="pass123",
            full_name="Test Owner",
            role=User.Role.OWNER,
            is_verified=True,
        )
        self.mechanic_user = User.objects.create_user(
            phone="256722222222",
            password="pass123",
            full_name="Test Mechanic",
            role=User.Role.MECHANIC,
            is_verified=True,
        )
        MechanicProfile.objects.create(
            user=self.mechanic_user,
            garage_name="Campus Garage",
            specialty="Roadside",
            services=["roadside", "battery"],
            address="Makerere",
            area="Makerere",
            latitude=0.3291,
            longitude=32.5686,
            is_verified=True,
            is_available=True,
            price_min=40000,
            price_max=90000,
        )

    def auth(self, user):
        response = self.client.post(
            "/api/auth/login/",
            {"phone": user.phone, "password": "pass123"},
            format="json",
        )
        self.assertEqual(response.status_code, 200)
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {response.data['access']}")

    def test_nearby_search_and_roadside_flow(self):
        self.auth(self.owner)
        nearby = self.client.get("/api/mechanics/nearby/", {"lat": 0.3291, "lng": 32.5686})
        self.assertEqual(nearby.status_code, 200)
        self.assertGreaterEqual(len(nearby.data), 1)
        mechanic_id = nearby.data[0]["id"]

        created = self.client.post(
            "/api/jobs/requests/",
            {
                "kind": "roadside",
                "description": "Battery died near Wandegeya",
                "latitude": 0.337,
                "longitude": 32.572,
                "address": "Wandegeya",
                "mechanic": mechanic_id,
            },
            format="json",
        )
        self.assertEqual(created.status_code, 201)
        job_id = created.data["id"]

        self.auth(self.mechanic_user)
        accepted = self.client.post(f"/api/jobs/requests/{job_id}/accept/")
        self.assertEqual(accepted.status_code, 200)
        self.assertEqual(accepted.data["status"], "accepted")

        self.client.post(f"/api/jobs/requests/{job_id}/status/", {"status": "completed"}, format="json")

        self.auth(self.owner)
        rated = self.client.post(
            f"/api/jobs/requests/{job_id}/rate/",
            {"stars": 5, "comment": "Arrived quickly"},
            format="json",
        )
        self.assertEqual(rated.status_code, 200)
        paid = self.client.post(
            f"/api/jobs/requests/{job_id}/pay/",
            {"amount": 40000, "momo_phone": "256711111111"},
            format="json",
        )
        self.assertEqual(paid.status_code, 200)
        self.assertEqual(paid.data["status"], "confirmed")

    def test_job_detail_is_private(self):
        self.auth(self.owner)
        created = self.client.post(
            "/api/jobs/requests/",
            {
                "kind": "roadside",
                "description": "Private request",
                "latitude": 0.337,
                "longitude": 32.572,
                "address": "Wandegeya",
            },
            format="json",
        )
        self.assertEqual(created.status_code, 201)

        other_user = User.objects.create_user(
            phone="256733333333",
            password="pass123",
            full_name="Other Owner",
            role=User.Role.OWNER,
            is_verified=True,
        )
        self.auth(other_user)
        response = self.client.get(f"/api/jobs/requests/{created.data['id']}/")

        self.assertEqual(response.status_code, 404)
