# MekaFix hosting setup (Render API + PostgreSQL, Vercel Flutter Web)

## Before deployment
1. Make sure the local project works and all database migrations are applied locally.
2. Push the whole `mekafix-new` project to a GitHub repository. Do not commit `.env`, `.venv`, `db.sqlite3`, passwords, or secret keys.
3. The Render blueprint is at the repository root: `render.yaml`.

## Deploy Django + PostgreSQL to Render
1. Sign in to Render and connect the GitHub repository.
2. Choose **New > Blueprint** and select this repository. Render reads `render.yaml` and creates the PostgreSQL database and Django web service.
3. Wait for the first deploy to finish. Open the service URL plus `/api/health/`; it should return `{"status":"ok","service":"MekaFix"}`.
4. In the Render service Shell, run `python manage.py createsuperuser` to create the admin account.
5. The blueprint uses free plans for a first test. Check Render's current free-tier limits and use a paid database before storing important real user data; free database availability/retention and free web-service sleep limits can change.

The Render build command installs dependencies, collects Django admin static files, and applies migrations. The start command runs Gunicorn. The service uses PostgreSQL through `DATABASE_URL` and retains SQLite only for local development.

## Deploy Flutter Web to Vercel (optional browser version)
The Android Flutter app does not need Vercel. Vercel is only for the browser version.
1. In Vercel, choose **Add New > Project** and import the same GitHub repository.
2. Set **Root Directory** to `mobile/mekafix`.
3. Vercel should read `vercel.json`. Build command: `bash ./vercel-build.sh`; output directory: `build/web`.
4. Add an environment variable named `API_BASE` with the Render service origin only, e.g. `https://mekafix-api.onrender.com` (no trailing slash and do not add `/api`).
5. Deploy. The script downloads Flutter stable, gets Dart packages, and builds the web app with the Render API URL compiled into it.
6. Copy the final Vercel domain. In Render service environment variables, replace `YOUR-VERCEL-DOMAIN.vercel.app` in both `CORS_ALLOWED_ORIGINS` and `CSRF_TRUSTED_ORIGINS` with the real Vercel origin, then redeploy Render.

## Point the Android app at Render
For a release build, run from `mobile/mekafix`:

```bash
flutter pub get
flutter build apk --release --dart-define=API_BASE=https://YOUR-RENDER-SERVICE.onrender.com
```

Replace the URL with the real Render service origin. Do not add `/api`; `ApiClient` appends `/api` itself.

## Test after deployment
- Open `https://YOUR-RENDER-SERVICE.onrender.com/api/health/`.
- Register a driver account and log in.
- Register a mechanic account; verify it appears in Django Admin and approve it if the app requires verification.
- Test mechanic search, job request, accept/reject, reassignment, and service records.
- Test the Android build against the live API.

## Production limitations to resolve before real public launch
- Phone OTP is still a fixed demo implementation (`DEMO_OTP_CODE`, default `123456`). Integrate a real SMS/OTP provider before relying on phone verification.
- Push notifications are not connected to Firebase (`FCM_ENABLED=False`).
- Payments are still the existing sandbox flow; do not accept real payments until a live provider integration is completed and tested.
- Hospital lookup and routing use public OpenStreetMap/OSRM services and need production-grade provider/data review.
- Set a real Vercel origin in Render CORS/CSRF settings. Do not leave the placeholder domain.
- Use a paid, backed-up PostgreSQL database before storing important production records.
