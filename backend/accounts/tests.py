from rest_framework.test import APITestCase

from accounts.models import User


class AccountApiTests(APITestCase):
    def test_public_registration_cannot_create_admin(self):
        response = self.client.post(
            "/api/auth/register/",
            {
                "phone": "256733333333",
                "full_name": "Unexpected Admin",
                "password": "pass123",
                "role": User.Role.ADMIN,
            },
            format="json",
        )

        self.assertEqual(response.status_code, 400)
        self.assertFalse(User.objects.filter(phone="256733333333").exists())
