from django.core.management.base import BaseCommand

from accounts.models import User
from jobs.models import Vehicle
from mechanics.models import MechanicProfile


MECHANICS = [
    {
        "phone": "256700111001",
        "full_name": "Ronald Ssemakula",
        "garage_name": "Ronald's Wandegeya Garage",
        "specialty": "Toyota and light commercial",
        "services": ["engine", "brakes", "roadside", "battery"],
        "address": "Wandegeya, Kampala",
        "area": "Wandegeya",
        "latitude": 0.3372,
        "longitude": 32.5728,
        "price_min": 40000,
        "price_max": 180000,
        "rating_avg": 4.7,
        "rating_count": 28,
        "bio": "Independent mechanic serving Makerere and Wandegeya drivers.",
        "is_featured": True,
    },
    {
        "phone": "256700111002",
        "full_name": "Amina Nalubega",
        "garage_name": "Makerere Quick Fix",
        "specialty": "Roadside and electrics",
        "services": ["roadside", "electrics", "tyres"],
        "address": "Makerere Hill Road",
        "area": "Makerere",
        "latitude": 0.3294,
        "longitude": 32.5701,
        "price_min": 35000,
        "price_max": 120000,
        "rating_avg": 4.5,
        "rating_count": 19,
        "bio": "Fast roadside help for campus and Kikoni breakdowns.",
        "is_featured": True,
    },
    {
        "phone": "256700111003",
        "full_name": "Peter Okello",
        "garage_name": "Kikoni Motors",
        "specialty": "General repairs",
        "services": ["general repair", "service", "oil change"],
        "address": "Kikoni, Kampala",
        "area": "Kikoni",
        "latitude": 0.3328,
        "longitude": 32.5619,
        "price_min": 30000,
        "price_max": 150000,
        "rating_avg": 4.2,
        "rating_count": 14,
        "bio": "Small garage with service history tracking for regulars.",
        "is_featured": False,
    },
    {
        "phone": "256700111004",
        "full_name": "Hassan Kato",
        "garage_name": "Nakawa Breakdown Aid",
        "specialty": "Tow and roadside",
        "services": ["roadside", "towing", "tyres"],
        "address": "Nakawa, Kampala",
        "area": "Nakawa",
        "latitude": 0.3359,
        "longitude": 32.6204,
        "price_min": 50000,
        "price_max": 250000,
        "rating_avg": 4.6,
        "rating_count": 22,
        "bio": "Breakdown truck and tyre service across Kampala east.",
        "is_featured": False,
    },
    {
        "phone": "256700111005",
        "full_name": "Sarah Atim",
        "garage_name": "Ntinda Auto Care",
        "specialty": "Diagnostics",
        "services": ["diagnostics", "engine", "service"],
        "address": "Ntinda, Kampala",
        "area": "Ntinda",
        "latitude": 0.3604,
        "longitude": 32.6136,
        "price_min": 45000,
        "price_max": 200000,
        "rating_avg": 4.8,
        "rating_count": 31,
        "bio": "Verified diagnostics and booked servicing.",
        "is_featured": True,
    },
]


class Command(BaseCommand):
    help = "Load Kampala demo owners, mechanics and a sample vehicle."

    def handle(self, *args, **options):
        admin, _ = User.objects.get_or_create(
            phone="256700000000",
            defaults={
                "full_name": "MekaFix Admin",
                "role": User.Role.ADMIN,
                "is_staff": True,
                "is_superuser": True,
                "is_verified": True,
            },
        )
        admin.set_password("admin123")
        admin.save()

        grace, _ = User.objects.get_or_create(
            phone="256700000001",
            defaults={
                "full_name": "Grace Namukasa",
                "role": User.Role.OWNER,
                "is_verified": True,
            },
        )
        grace.set_password("pass123")
        grace.save()
        Vehicle.objects.get_or_create(
            owner=grace,
            plate="UAX 123K",
            defaults={"make": "Toyota", "model": "Corolla", "year": 2014},
        )

        for item in MECHANICS:
            user, _ = User.objects.get_or_create(
                phone=item["phone"],
                defaults={
                    "full_name": item["full_name"],
                    "role": User.Role.MECHANIC,
                    "is_verified": True,
                },
            )
            user.set_password("pass123")
            user.is_verified = True
            user.save()
            MechanicProfile.objects.update_or_create(
                user=user,
                defaults={
                    "garage_name": item["garage_name"],
                    "specialty": item["specialty"],
                    "services": item["services"],
                    "address": item["address"],
                    "area": item["area"],
                    "latitude": item["latitude"],
                    "longitude": item["longitude"],
                    "price_min": item["price_min"],
                    "price_max": item["price_max"],
                    "rating_avg": item["rating_avg"],
                    "rating_count": item["rating_count"],
                    "bio": item["bio"],
                    "is_verified": True,
                    "is_available": True,
                    "is_featured": item["is_featured"],
                    "roadside_supported": True,
                },
            )
        self.stdout.write(self.style.SUCCESS("Seeded MekaFix demo users and Kampala mechanics."))
