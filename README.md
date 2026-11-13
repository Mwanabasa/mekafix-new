# MekaFix

Mobile app that connects vehicle owners around Makerere, Wandegeya and Kampala with **verified nearby mechanics**, **roadside assistance with live location**, **appointment booking**, **ratings**, **SMS fallback**, and a **mobile-money sandbox**.

Built from the Group 7 capstone concept paper, using **Django REST Framework** (backend) and **Flutter** (Android-first).

## What is implemented (MVP)

| Concept paper feature | Status |
| --- | --- |
| Phone registration & login | Done |
| Mechanic search by GPS, rating, distance | Done |
| Roadside request with live location | Done |
| Appointment booking | Done |
| Ratings after completion | Done |
| Push/SMS notification log (FCM hook + SMS fallback) | Done (logged; FCM send is off until keys exist) |
| Offline SQLite cache + pending rating queue | Done in Flutter |
| Vehicle service history | Done (vehicles + job history API) |
| Mobile money sandbox “mark as paid” | Done |
| Tap-to-call instead of live chat | Done |

## Demo accounts (after seed)

| Role | Phone | Password |
| --- | --- | --- |
| Owner (Grace) | `256700000001` | `pass123` |
| Mechanic (Ronald, Wandegeya) | `256700111001` | `pass123` |
| Admin | `256700000000` | `admin123` |

OTP demo code: `123456`.

## Backend (Django REST)

```powershell
cd backend
.\.venv\Scripts\activate
python manage.py migrate
python manage.py seed_demo
python manage.py runserver 0.0.0.0:8000
```

Admin: http://127.0.0.1:8000/admin/  
Health: http://127.0.0.1:8000/api/health/

### Main API routes

- `POST /api/auth/register/`
- `POST /api/auth/login/`
- `POST /api/auth/otp/request/` and `POST /api/auth/otp/verify/`
- `GET /api/auth/me/`
- `GET /api/mechanics/nearby/?lat=&lng=&radius_km=15&service=brakes`
- `GET /api/mechanics/<id>/`
- `GET/PATCH /api/mechanics/me/`
- `POST /api/jobs/requests/` (`kind`: `roadside` or `booking`)
- `POST /api/jobs/requests/<id>/accept/`
- `POST /api/jobs/requests/<id>/status/`
- `POST /api/jobs/requests/<id>/rate/`
- `POST /api/jobs/requests/<id>/pay/`
- `GET /api/jobs/vehicles/` and `GET /api/jobs/vehicles/<id>/history/`
- `GET /api/notifications/`

Tests:

```powershell
cd backend
.\.venv\Scripts\python.exe manage.py test jobs
```

PostgreSQL can replace SQLite later by setting `DATABASES` in `backend/config/settings.py`. The models are portable.

## Flutter app (Android-first)

Flutter SDK is **not** currently on this machine. Install [Flutter](https://docs.flutter.dev/get-started/install/windows), then:

```powershell
cd mobile\mekafix
flutter create . --org com.mekafix --project-name mekafix --platforms android
```

`flutter create .` adds the Android Gradle wrapper without wiping `lib/`. Then add location + internet permissions in `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

Inside `android/app/src/main/AndroidManifest.xml` `<application>` add:

```xml
android:usesCleartextTraffic="true"
```

(needed so the app can talk to `http://10.0.2.2:8000` in debug).

Run against the Django server:

```powershell
# Android emulator (default API host in lib/core/config.dart)
flutter run

# Physical phone on the same Wi-Fi — replace with your PC IP
flutter run --dart-define=API_BASE=http://192.168.x.x:8000
```

Default GPS fallback if permission is denied: Makerere (`0.3291, 32.5686`).

## Suggested demo flow

1. Sign in as Grace (`256700000001`).
2. Open **Find help** — nearby Kampala garages sorted by distance and rating.
3. Toggle the map, open Ronald’s garage, **Request roadside assistance**.
4. Sign in as Ronald (`256700111001`) and **Accept**.
5. Mark the job `en_route` → `completed`.
6. As Grace, rate the job and **Mark paid (MoMo sandbox)**.
7. Check **Me → Notifications** for SMS/push logs.

## Architecture

```
Flutter (owner / mechanic)
   HTTPS REST
Django REST + JWT
   SQLite (dev) / PostgreSQL (prod-ready models)
Notification log (push + SMS fallback)
```

Maps use OpenStreetMap tiles so the demo does not require a paid Google Maps key. Swap in Google Maps later if the team has an API key.
