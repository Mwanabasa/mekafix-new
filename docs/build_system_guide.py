"""Generate the MekaFix system guide PDF."""

from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_JUSTIFY, TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.platypus import (
    KeepTogether,
    ListFlowable,
    ListItem,
    PageBreak,
    Paragraph,
    SimpleDocTemplate,
    Spacer,
    Table,
    TableStyle,
)

GREEN = colors.HexColor("#0B6E4F")
DARK = colors.HexColor("#10231C")
AMBER = colors.HexColor("#F4A261")
PALE = colors.HexColor("#E8F3EE")
LINE = colors.HexColor("#C5D9D0")
WHITE = colors.white

OUT = Path(__file__).resolve().parent / "MekaFix_System_Guide.pdf"


def styles():
    base = getSampleStyleSheet()
    s = {
        "cover_kicker": ParagraphStyle(
            "cover_kicker",
            parent=base["Normal"],
            fontName="Times-Bold",
            fontSize=11,
            textColor=GREEN,
            alignment=TA_CENTER,
            letterSpacing=1.2,
            spaceAfter=8,
        ),
        "cover_title": ParagraphStyle(
            "cover_title",
            parent=base["Title"],
            fontName="Times-Bold",
            fontSize=28,
            textColor=DARK,
            alignment=TA_CENTER,
            leading=34,
            spaceAfter=10,
        ),
        "cover_sub": ParagraphStyle(
            "cover_sub",
            parent=base["Normal"],
            fontName="Times-Italic",
            fontSize=13,
            textColor=colors.HexColor("#3D5249"),
            alignment=TA_CENTER,
            leading=18,
            spaceAfter=6,
        ),
        "h1": ParagraphStyle(
            "h1",
            parent=base["Heading1"],
            fontName="Times-Bold",
            fontSize=16,
            textColor=GREEN,
            spaceBefore=14,
            spaceAfter=8,
            borderPadding=3,
        ),
        "h2": ParagraphStyle(
            "h2",
            parent=base["Heading2"],
            fontName="Times-Bold",
            fontSize=13,
            textColor=DARK,
            spaceBefore=10,
            spaceAfter=6,
        ),
        "body": ParagraphStyle(
            "body",
            parent=base["Normal"],
            fontName="Times-Roman",
            fontSize=10.5,
            leading=15,
            textColor=DARK,
            alignment=TA_JUSTIFY,
            spaceAfter=8,
        ),
        "bullet": ParagraphStyle(
            "bullet",
            parent=base["Normal"],
            fontName="Times-Roman",
            fontSize=10.5,
            leading=14.5,
            textColor=DARK,
            leftIndent=8,
        ),
        "caption": ParagraphStyle(
            "caption",
            parent=base["Normal"],
            fontName="Times-Italic",
            fontSize=9,
            textColor=colors.HexColor("#4A5C55"),
            alignment=TA_CENTER,
            spaceBefore=4,
            spaceAfter=10,
        ),
        "mono": ParagraphStyle(
            "mono",
            parent=base["Normal"],
            fontName="Courier",
            fontSize=8.2,
            leading=11.5,
            textColor=DARK,
            leftIndent=4,
        ),
        "th": ParagraphStyle(
            "th",
            parent=base["Normal"],
            fontName="Times-Bold",
            fontSize=9,
            textColor=WHITE,
            leading=12,
        ),
        "td": ParagraphStyle(
            "td",
            parent=base["Normal"],
            fontName="Times-Roman",
            fontSize=8.6,
            textColor=DARK,
            leading=11.5,
        ),
        "footer": ParagraphStyle(
            "footer",
            parent=base["Normal"],
            fontName="Times-Roman",
            fontSize=8,
            textColor=colors.HexColor("#5A6E66"),
        ),
        "step": ParagraphStyle(
            "step",
            parent=base["Normal"],
            fontName="Times-Roman",
            fontSize=10.5,
            leading=15,
            textColor=DARK,
            leftIndent=14,
            spaceAfter=4,
        ),
    }
    return s


def header_footer(canvas, doc):
    canvas.saveState()
    canvas.setFillColor(GREEN)
    canvas.rect(0, A4[1] - 8 * mm, A4[0], 8 * mm, fill=1, stroke=0)
    canvas.setFillColor(WHITE)
    canvas.setFont("Times-Bold", 8)
    canvas.drawString(18 * mm, A4[1] - 5.2 * mm, "MekaFix  ·  System Guide")
    canvas.drawRightString(A4[0] - 18 * mm, A4[1] - 5.2 * mm, "Group 7 Capstone")
    canvas.setFillColor(GREEN)
    canvas.rect(0, 0, A4[0], 12 * mm, fill=1, stroke=0)
    canvas.setFillColor(WHITE)
    canvas.setFont("Times-Roman", 8)
    canvas.drawString(18 * mm, 5 * mm, "Django REST Framework  +  Flutter")
    canvas.drawRightString(A4[0] - 18 * mm, 5 * mm, f"Page {doc.page}")
    canvas.restoreState()


def table(data, col_widths):
    t = Table(data, colWidths=col_widths, repeatRows=1)
    t.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, 0), GREEN),
                ("TEXTCOLOR", (0, 0), (-1, 0), WHITE),
                ("FONTNAME", (0, 0), (-1, 0), "Times-Bold"),
                ("FONTSIZE", (0, 0), (-1, -1), 8.6),
                ("BACKGROUND", (0, 1), (-1, -1), WHITE),
                ("ROWBACKGROUNDS", (0, 1), (-1, -1), [WHITE, PALE]),
                ("GRID", (0, 0), (-1, -1), 0.3, LINE),
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ("LEFTPADDING", (0, 0), (-1, -1), 6),
                ("RIGHTPADDING", (0, 0), (-1, -1), 6),
                ("TOPPADDING", (0, 0), (-1, -1), 5),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
            ]
        )
    )
    return t


def bullets(items, s):
    return ListFlowable(
        [ListItem(Paragraph(i, s["bullet"]), leftIndent=12, bulletColor=GREEN) for i in items],
        bulletType="bullet",
        start="circle",
        leftIndent=18,
        bulletFontName="Times-Roman",
        bulletFontSize=9,
    )


def build():
    s = styles()
    story = []

    story.append(Spacer(1, 42 * mm))
    story.append(Paragraph("SEMESTER CAPSTONE  ·  GROUP 7", s["cover_kicker"]))
    story.append(Paragraph("MekaFix System Guide", s["cover_title"]))
    story.append(
        Paragraph(
            "How the Flutter mobile app and Django REST backend work,<br/>how they connect, and how users complete tasks.",
            s["cover_sub"],
        )
    )
    story.append(Spacer(1, 8 * mm))
    cover_meta = [
        [Paragraph("Document", s["th"]), Paragraph("MekaFix Front-End, Back-End and User Tasks", s["td"])],
        [Paragraph("Stack", s["th"]), Paragraph("Flutter (Android-first) + Django REST Framework + JWT", s["td"])],
        [Paragraph("Scope", s["th"]), Paragraph("Makerere, Wandegeya and greater Kampala roadside and garage services", s["td"])],
        [Paragraph("Audience", s["th"]), Paragraph("Team members, examiners, and demo facilitators", s["td"])],
    ]
    meta = Table(cover_meta, colWidths=[32 * mm, 130 * mm])
    meta.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (0, -1), GREEN),
                ("TEXTCOLOR", (0, 0), (0, -1), WHITE),
                ("BACKGROUND", (1, 0), (1, -1), PALE),
                ("BOX", (0, 0), (-1, -1), 0.5, GREEN),
                ("INNERGRID", (0, 0), (-1, -1), 0.3, LINE),
                ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
                ("LEFTPADDING", (0, 0), (-1, -1), 8),
                ("TOPPADDING", (0, 0), (-1, -1), 6),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 6),
            ]
        )
    )
    story.append(meta)
    story.append(PageBreak())

    # 1
    story.append(Paragraph("1. Purpose of this document", s["h1"]))
    story.append(
        Paragraph(
            "MekaFix is a mobile application that connects vehicle owners with verified nearby mechanics. "
            "This guide explains the implemented system: the Flutter client, the Django REST cloud API, "
            "the HTTPS contract that joins them, the product features, and the exact taps a driver or mechanic "
            "makes to finish a job. It is written from the running codebase, not from the concept paper alone.",
            s["body"],
        )
    )
    story.append(
        Paragraph(
            "The product solves a practical Kampala problem: when a car fails, people currently rely on "
            "passers-by, boda riders, WhatsApp and phone calls. MekaFix replaces that with GPS search, "
            "verified garage profiles, estimated prices, roadside location sharing, booking, ratings, "
            "SMS fallback for low connectivity, and a mobile-money sandbox payment step.",
            s["body"],
        )
    )

    # 2
    story.append(Paragraph("2. High-level architecture", s["h1"]))
    story.append(
        Paragraph(
            "The system is layered. The phone is a thin, role-aware client. The cloud holds accounts, "
            "mechanic profiles, jobs, ratings, payments and notification logs. Supporting services sit beside the API.",
            s["body"],
        )
    )
    arch = [
        [Paragraph("Layer", s["th"]), Paragraph("Technology", s["th"]), Paragraph("Responsibility", s["th"])],
        [
            Paragraph("Mobile client", s["td"]),
            Paragraph("Flutter, Android-first", s["td"]),
            Paragraph("Screens, GPS, maps, tap-to-call, SQLite offline cache, JWT session", s["td"]),
        ],
        [
            Paragraph("Transport", s["td"]),
            Paragraph("HTTPS REST JSON", s["td"]),
            Paragraph("All app traffic uses REST over HTTP(S). No MQTT or live WebSocket chat in the MVP.", s["td"]),
        ],
        [
            Paragraph("API &amp; logic", s["td"]),
            Paragraph("Django REST Framework", s["td"]),
            Paragraph("Auth, geo search, jobs, ratings, sandbox payments, SMS/push logging", s["td"]),
        ],
        [
            Paragraph("Identity", s["td"]),
            Paragraph("SimpleJWT", s["td"]),
            Paragraph("Access token in the Authorization: Bearer header after phone login or OTP verify", s["td"]),
        ],
        [
            Paragraph("Data", s["td"]),
            Paragraph("SQLite (dev) / PostgreSQL-ready models", s["td"]),
            Paragraph("Users, mechanic profiles, vehicles, service requests, ratings, payments, notification logs", s["td"]),
        ],
        [
            Paragraph("Maps", s["td"]),
            Paragraph("OpenStreetMap via flutter_map", s["td"]),
            Paragraph("Nearby pins without a paid Google Maps key; GPS still comes from the device", s["td"]),
        ],
        [
            Paragraph("Alerts", s["td"]),
            Paragraph("Notification log + FCM hook + SMS fallback", s["td"]),
            Paragraph("Critical events (accept, complete) are stored as push and SMS records for the inbox", s["td"]),
        ],
        [
            Paragraph("Admin", s["td"]),
            Paragraph("Django Admin", s["td"]),
            Paragraph("Verify mechanics, inspect jobs, complaints-style records, seed data", s["td"]),
        ],
    ]
    story.append(table(arch, [32 * mm, 48 * mm, 82 * mm]))
    story.append(Paragraph("Figure 1. MekaFix system layers.", s["caption"]))

    story.append(Paragraph("Logical request path", s["h2"]))
    story.append(
        Paragraph(
            "<b>Phone GPS</b> → Flutter Dio client → <b>/api/...</b> on Django → models and haversine search → "
            "JSON response → Flutter Provider state → list, map or job screen. Notifications are written on the "
            "server at the same time as status changes, then listed on the Profile tab.",
            s["body"],
        )
    )
    story.append(Paragraph("Typical connection diagram", s["h2"]))
    story.append(
        Paragraph(
            "Vehicle owner app  and  Mechanic app  (same Flutter binary, different navigation)<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;│  REST + JWT<br/>"
            "MekaFix Cloud  (accounts, mechanics, jobs, notifications)<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;├─ Device GPS / last known location<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;├─ OpenStreetMap tiles on the phone<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;├─ SMS fallback log for low connectivity<br/>"
            "&nbsp;&nbsp;&nbsp;&nbsp;└─ Mobile-money sandbox confirmation (not a live merchant settlement)",
            s["mono"],
        )
    )

    # 3
    story.append(Paragraph("3. How the front end works", s["h1"]))
    story.append(
        Paragraph(
            "The Flutter app is a single Android-first codebase. After login, the user’s <b>role</b> "
            "(owner or mechanic) chooses the bottom navigation. Owners see Find help, Requests and Me. "
            "Mechanics see Jobs, Map and Profile. There is no separate mechanic APK.",
            s["body"],
        )
    )
    story.append(Paragraph("Client building blocks", s["h2"]))
    fe = [
        [Paragraph("Piece", s["th"]), Paragraph("Where", s["th"]), Paragraph("What it does", s["th"])],
        [
            Paragraph("SessionState", s["td"]),
            Paragraph("lib/state/session.dart", s["td"]),
            Paragraph("Login, register, JWT storage, GPS, device location post", s["td"]),
        ],
        [
            Paragraph("MechanicState", s["td"]),
            Paragraph("lib/state/mechanic_state.dart", s["td"]),
            Paragraph("Nearby search, radius filter, offline mechanic cache", s["td"]),
        ],
        [
            Paragraph("JobsState", s["td"]),
            Paragraph("lib/state/jobs_state.dart", s["td"]),
            Paragraph("Create jobs, accept, status, rate, pay, vehicles, flush offline queue", s["td"]),
        ],
        [
            Paragraph("ApiClient", s["td"]),
            Paragraph("lib/core/api.dart", s["td"]),
            Paragraph("Dio HTTP client. Base URL /api plus Bearer token interceptor", s["td"]),
        ],
        [
            Paragraph("OfflineStore", s["td"]),
            Paragraph("lib/core/offline.dart", s["td"]),
            Paragraph("SQLite: last mechanic list + pending rating actions until the network returns", s["td"]),
        ],
        [
            Paragraph("ApiConfig", s["td"]),
            Paragraph("lib/core/config.dart", s["td"]),
            Paragraph("Default http://10.0.2.2:8000 for the Android emulator; override with --dart-define=API_BASE", s["td"]),
        ],
    ]
    story.append(table(fe, [36 * mm, 52 * mm, 74 * mm]))
    story.append(Paragraph("Figure 2. Front-end modules.", s["caption"]))

    story.append(
        Paragraph(
            "On a cold start the app reads the saved access token, calls <b>GET /api/auth/me/</b>, and either "
            "opens the home shell or the login screen. Location is requested with Geolocator. If permission is "
            "denied, Makerere coordinates (0.3291, 32.5686) are used so nearby search still works for the campus demo. "
            "Maps are OpenStreetMap tiles with pins for the user and each garage. Calling a mechanic uses the "
            "phone dialer (tap-to-call), matching the concept paper’s choice to skip live in-app chat for the MVP.",
            s["body"],
        )
    )
    story.append(Paragraph("Main screens", s["h2"]))
    screens = [
        [Paragraph("Screen", s["th"]), Paragraph("Users", s["th"]), Paragraph("Job of the screen", s["th"])],
        [Paragraph("Login / Register", s["td"]), Paragraph("All", s["td"]), Paragraph("Phone number + password; owner vs mechanic on register", s["td"])],
        [Paragraph("Find help / Map", s["td"]), Paragraph("Owners (mechanics can browse too)", s["td"]), Paragraph("Search by service, sort by distance and rating, map toggle", s["td"])],
        [Paragraph("Mechanic detail", s["td"]), Paragraph("Owners", s["td"]), Paragraph("Bio, estimate band, verified badge, call, roadside, booking", s["td"])],
        [Paragraph("Roadside / Booking form", s["td"]), Paragraph("Owners", s["td"]), Paragraph("Problem text, address, vehicle, live lat/lng, optional appointment time", s["td"])],
        [Paragraph("My requests", s["td"]), Paragraph("Owners", s["td"]), Paragraph("List of jobs; open detail to rate or mark paid", s["td"])],
        [Paragraph("Jobs inbox", s["td"]), Paragraph("Mechanics", s["td"]), Paragraph("Incoming work; Accept; then en route / in progress / completed", s["td"])],
        [Paragraph("Job detail", s["td"]), Paragraph("Both", s["td"]), Paragraph("Status, estimate, call the other party, rate, sandbox pay", s["td"])],
        [Paragraph("Profile / Me", s["td"]), Paragraph("Both", s["td"]), Paragraph("Vehicles, notification log, go-available (mechanic), sign out", s["td"])],
    ]
    story.append(table(screens, [42 * mm, 40 * mm, 80 * mm]))
    story.append(Paragraph("Figure 3. Mobile screens.", s["caption"]))

    # 4
    story.append(Paragraph("4. How the back end works", s["h1"]))
    story.append(
        Paragraph(
            "Django exposes JSON under <b>/api/</b>. Business rules live in views: only a mechanic can accept a job; "
            "only the customer can rate after completion; only verified mechanics appear in nearby search; "
            "quoted amount defaults to the garage’s minimum estimate. The admin site is the verification desk.",
            s["body"],
        )
    )
    story.append(Paragraph("Django apps", s["h2"]))
    be = [
        [Paragraph("App", s["th"]), Paragraph("Stores", s["th"]), Paragraph("Key behaviour", s["th"])],
        [
            Paragraph("accounts", s["td"]),
            Paragraph("User (phone as login), PhoneOTP", s["td"]),
            Paragraph("Register, login, OTP 123456 (demo), /me, FCM token + last GPS", s["td"]),
        ],
        [
            Paragraph("mechanics", s["td"]),
            Paragraph("MechanicProfile", s["td"]),
            Paragraph("Verified flag, availability, services JSON, haversine nearby sort", s["td"]),
        ],
        [
            Paragraph("jobs", s["td"]),
            Paragraph("Vehicle, ServiceRequest, Rating, Payment", s["td"]),
            Paragraph("Roadside vs booking, status machine, ratings that update garage averages, MoMo sandbox", s["td"]),
        ],
        [
            Paragraph("notifications", s["td"]),
            Paragraph("NotificationLog", s["td"]),
            Paragraph("Writes push and SMS rows when jobs change; listed to the user", s["td"]),
        ],
        [
            Paragraph("config", s["td"]),
            Paragraph("Project settings", s["td"]),
            Paragraph("CORS open for demo, JWT lifetime 7 days, Africa/Kampala timezone", s["td"]),
        ],
    ]
    story.append(table(be, [32 * mm, 52 * mm, 78 * mm]))
    story.append(Paragraph("Figure 4. Backend apps.", s["caption"]))

    story.append(Paragraph("Job status machine", s["h2"]))
    story.append(
        Paragraph(
            "<b>pending</b> → (mechanic Accept) <b>accepted</b> → <b>en_route</b> → <b>in_progress</b> → "
            "<b>completed</b>. The owner may also see <b>cancelled</b>. Rating is allowed only on completed jobs. "
            "Sandbox payment can be confirmed once an amount exists (quoted_amount or explicit amount).",
            s["body"],
        )
    )
    story.append(Paragraph("Geo search", s["h2"]))
    story.append(
        Paragraph(
            "Nearby search accepts lat, lng, optional radius_km (default used by the app is 15 km), optional service "
            "text, and available=1. Distance is computed with the haversine formula. Results are sorted by distance, "
            "then rating. Unverified garages are hidden from the public list so trust matches the concept paper.",
            s["body"],
        )
    )

    # 5
    story.append(Paragraph("5. How front end and back end are connected", s["h1"]))
    story.append(
        Paragraph(
            "The phone never talks to the database. Every read and write goes through REST. After login, Dio attaches "
            "<b>Authorization: Bearer &lt;access&gt;</b> to each call. The emulator reaches the developer PC at "
            "<b>10.0.2.2:8000</b>. A physical phone on Wi-Fi must use the PC’s LAN IP via "
            "<b>--dart-define=API_BASE=http://192.168.x.x:8000</b>. Cleartext HTTP is allowed only in debug so the "
            "semester demo can run without TLS certificates.",
            s["body"],
        )
    )
    story.append(Paragraph("API contract used by the app", s["h2"]))
    api = [
        [Paragraph("Method &amp; path", s["th"]), Paragraph("Called when", s["th"])],
        [Paragraph("POST /api/auth/register/", s["td"]), Paragraph("Create account; returns tokens immediately", s["td"])],
        [Paragraph("POST /api/auth/login/", s["td"]), Paragraph("Phone + password sign-in", s["td"])],
        [Paragraph("POST /api/auth/otp/request/ and /otp/verify/", s["td"]), Paragraph("SMS-style OTP path; demo code 123456", s["td"])],
        [Paragraph("GET /api/auth/me/", s["td"]), Paragraph("Restore session on app launch", s["td"])],
        [Paragraph("POST /api/auth/device/", s["td"]), Paragraph("Save FCM token and last latitude/longitude", s["td"])],
        [Paragraph("GET /api/mechanics/nearby/?lat=&amp;lng=&amp;radius_km=&amp;service=", s["td"]), Paragraph("Find help list and map pins", s["td"])],
        [Paragraph("GET /api/mechanics/&lt;id&gt;/", s["td"]), Paragraph("Mechanic profile detail", s["td"])],
        [Paragraph("GET/PATCH /api/mechanics/me/  and POST .../availability/", s["td"]), Paragraph("Mechanic updates garage or goes available at current GPS", s["td"])],
        [Paragraph("POST /api/jobs/requests/", s["td"]), Paragraph("Owner submits roadside or booking with live coordinates", s["td"])],
        [Paragraph("GET /api/jobs/requests/", s["td"]), Paragraph("Owner sees own jobs; mechanic sees assigned/incoming jobs", s["td"])],
        [Paragraph("POST .../accept/  .../status/  .../rate/  .../pay/", s["td"]), Paragraph("Accept, progress, rating, MoMo sandbox", s["td"])],
        [Paragraph("GET/POST /api/jobs/vehicles/  and .../history/", s["td"]), Paragraph("Car log for service history", s["td"])],
        [Paragraph("GET /api/notifications/", s["td"]), Paragraph("Push and SMS fallback records on Profile", s["td"])],
        [Paragraph("GET /api/health/", s["td"]), Paragraph("Server liveness check", s["td"])],
    ]
    story.append(table(api, [88 * mm, 74 * mm]))
    story.append(Paragraph("Figure 5. REST endpoints consumed by Flutter.", s["caption"]))

    story.append(Paragraph("End-to-end example: roadside request", s["h2"]))
    story.append(
        Paragraph(
            "1. Owner GPS is read on the phone.<br/>"
            "2. GET /api/mechanics/nearby/ returns garages with distance_km.<br/>"
            "3. Owner opens a garage and taps Request roadside assistance.<br/>"
            "4. POST /api/jobs/requests/ stores kind=roadside, description, lat/lng, optional mechanic id.<br/>"
            "5. Backend writes a push+SMS notification to the mechanic.<br/>"
            "6. Mechanic GET /api/jobs/requests/ shows the inbox item; POST .../accept/ sets status=accepted "
            "and notifies the owner.<br/>"
            "7. Mechanic advances status; owner rates and optionally POST .../pay/ for sandbox MoMo.",
            s["body"],
        )
    )
    story.append(Paragraph("Offline and low connectivity", s["h2"]))
    story.append(
        Paragraph(
            "If nearby search fails, Flutter shows the last mechanic list from SQLite and a banner "
            "“Showing last saved mechanics (offline).” If a rating POST fails, it is queued in pending_actions "
            "and flushed on the next successful refresh. Critical job events are also stored as SMS-channel "
            "notification logs so the concept of SMS fallback is demonstrable even before a paid SMS gateway is wired.",
            s["body"],
        )
    )

    # 6
    story.append(Paragraph("6. Features", s["h1"]))
    feat = [
        [Paragraph("Feature", s["th"]), Paragraph("Priority in concept paper", s["th"]), Paragraph("How it appears in this build", s["th"])],
        [Paragraph("Registration &amp; login (phone)", s["td"]), Paragraph("Must-have MVP", s["td"]), Paragraph("Phone is the username; password login; optional OTP 123456", s["td"])],
        [Paragraph("Search by GPS, rating, distance", s["td"]), Paragraph("Must-have MVP", s["td"]), Paragraph("Nearby API + list/map; radius 15 km; service filter", s["td"])],
        [Paragraph("Roadside + live location", s["td"]), Paragraph("Must-have MVP", s["td"]), Paragraph("Request form posts current lat/lng and address text", s["td"])],
        [Paragraph("Appointment booking", s["td"]), Paragraph("Must-have MVP", s["td"]), Paragraph("kind=booking with scheduled_at date/time picker", s["td"])],
        [Paragraph("Push notifications", s["td"]), Paragraph("Must-have MVP", s["td"]), Paragraph("FCM token field + in-app notification list; live FCM send is a hook", s["td"])],
        [Paragraph("Ratings &amp; reviews", s["td"]), Paragraph("Must-have MVP", s["td"]), Paragraph("Stars + comment after completed; updates mechanic average", s["td"])],
        [Paragraph("SMS fallback", s["td"]), Paragraph("Must-have MVP", s["td"]), Paragraph("NotificationLog channel=sms on accept/complete (gateway-ready)", s["td"])],
        [Paragraph("Vehicle service history", s["td"]), Paragraph("Nice to have", s["td"]), Paragraph("Vehicles on Profile; history API per vehicle", s["td"])],
        [Paragraph("In-app chat", s["td"]), Paragraph("Nice to have (deferred)", s["td"]), Paragraph("Replaced by tap-to-call as in the concept paper trade-off", s["td"])],
        [Paragraph("Mobile money", s["td"]), Paragraph("Nice to have / sandbox", s["td"]), Paragraph("Mark paid stores a confirmed sandbox reference", s["td"])],
        [Paragraph("Mechanic verification", s["td"]), Paragraph("Trust requirement", s["td"]), Paragraph("Admin sets is_verified; unverified garages are not listed", s["td"])],
        [Paragraph("Offline cache", s["td"]), Paragraph("Wireless computing", s["td"]), Paragraph("SQLite mechanic cache and queued ratings", s["td"])],
    ]
    story.append(table(feat, [42 * mm, 48 * mm, 72 * mm]))
    story.append(Paragraph("Figure 6. Features versus the concept paper.", s["caption"]))

    # 7
    story.append(Paragraph("7. How users perform tasks in the mobile app", s["h1"]))
    story.append(
        Paragraph(
            "Use two phones or two emulator users for a live demo: Grace the owner and Ronald the mechanic. "
            "Seeded passwords are pass123. Keep Django running on port 8000.",
            s["body"],
        )
    )

    story.append(Paragraph("7.1 Create an account or sign in", s["h2"]))
    story.append(Paragraph("<b>Owner or mechanic</b>", s["body"]))
    story.append(
        Paragraph(
            "1. Open MekaFix. If no token exists, the login screen appears.<br/>"
            "2. Existing user: enter phone (e.g. 256700000001) and password, tap <b>Sign in</b>.<br/>"
            "3. New user: tap <b>Create an account</b>, choose Vehicle owner or Mechanic, enter name, phone, "
            "password, and garage name if mechanic, then <b>Register with phone</b>.<br/>"
            "4. A JWT is stored on the device. The home shell opens according to role.",
            s["step"],
        )
    )

    story.append(Paragraph("7.2 Find a nearby verified mechanic", s["h2"]))
    story.append(Paragraph("<b>Owner (Find help tab)</b>", s["step"]))
    story.append(
        Paragraph(
            "1. Allow location when asked (or accept Makerere fallback).<br/>"
            "2. The list loads automatically from GET /mechanics/nearby/.<br/>"
            "3. Optionally type a service such as brakes, battery or roadside and tap search.<br/>"
            "4. Toggle the map icon to see pins. Your location is the blue marker; garages are green pins.<br/>"
            "5. Open a card to see estimate band (UGX min–max), rating, services and verified badge.",
            s["step"],
        )
    )

    story.append(Paragraph("7.3 Request roadside assistance", s["h2"]))
    story.append(Paragraph("<b>Owner</b>", s["step"]))
    story.append(
        Paragraph(
            "1. From Find help tap the orange <b>Roadside help</b> button, or open a mechanic and tap "
            "<b>Request roadside assistance</b>.<br/>"
            "2. Describe the fault (for example “battery died near Wandegeya”).<br/>"
            "3. Confirm the location description. The phone already attaches live latitude and longitude.<br/>"
            "4. Select a saved vehicle if one exists.<br/>"
            "5. Tap <b>Share live location &amp; request help</b>.<br/>"
            "6. A snackbar confirms the request. The job appears under <b>Requests</b>.",
            s["step"],
        )
    )

    story.append(Paragraph("7.4 Book a non-emergency appointment", s["h2"]))
    story.append(Paragraph("<b>Owner</b>", s["step"]))
    story.append(
        Paragraph(
            "1. Open a mechanic profile and tap <b>Book an appointment</b>.<br/>"
            "2. Describe the work (service, brakes, diagnostics).<br/>"
            "3. Tap <b>Pick appointment time</b> and choose date and time.<br/>"
            "4. Tap <b>Confirm booking</b>. The mechanic receives a notification log entry.",
            s["step"],
        )
    )

    story.append(Paragraph("7.5 Call instead of chatting", s["h2"]))
    story.append(
        Paragraph(
            "On mechanic detail or job detail, tap <b>Tap to call</b> / <b>Call mechanic</b> / <b>Call &lt;customer&gt;</b>. "
            "The Android dialer opens with the stored phone number. This is the MVP communication path.",
            s["body"],
        )
    )

    story.append(Paragraph("7.6 Mechanic: receive and accept work", s["h2"]))
    story.append(Paragraph("<b>Mechanic (Jobs tab)</b>", s["step"]))
    story.append(
        Paragraph(
            "1. Sign in as 256700111001 (Ronald) or another verified mechanic.<br/>"
            "2. Pull to refresh the inbox. New roadside and booking jobs appear with customer name and description.<br/>"
            "3. Tap <b>Accept</b>. Status becomes accepted. The owner is notified (push + SMS log).<br/>"
            "4. Open the job. Tap <b>en route</b>, then <b>in progress</b>, then <b>completed</b> as the work proceeds.<br/>"
            "5. Call the driver if directions are unclear.",
            s["step"],
        )
    )

    story.append(Paragraph("7.7 Mechanic: stay visible in search", s["h2"]))
    story.append(
        Paragraph(
            "On Profile tap <b>Go available at my current location</b>. The app posts availability and GPS so the "
            "garage remains in nearby results while the mechanic is on duty.",
            s["body"],
        )
    )

    story.append(Paragraph("7.8 Rate a completed job", s["h2"]))
    story.append(Paragraph("<b>Owner (Requests → job detail)</b>", s["step"]))
    story.append(
        Paragraph(
            "1. Wait until the mechanic has marked the job completed.<br/>"
            "2. Tap <b>Rate this job</b>. Slide 1–5 stars and add a short comment.<br/>"
            "3. Submit. If the network is down, the rating is stored on-device and sent later.<br/>"
            "4. The garage’s public average and review count update on the next search.",
            s["step"],
        )
    )

    story.append(Paragraph("7.9 Pay with the mobile-money sandbox", s["h2"]))
    story.append(
        Paragraph(
            "On a job that has an estimate and is not yet paid, tap <b>Mark paid (MoMo sandbox)</b>. "
            "The API confirms a fake merchant reference (MOMO-SANDBOX-…). This demonstrates the payment "
            "step without a live MTN/Airtel merchant account, as planned in the concept paper.",
            s["body"],
        )
    )

    story.append(Paragraph("7.10 Keep a vehicle log", s["h2"]))
    story.append(
        Paragraph(
            "On Me, tap <b>Add vehicle</b>, enter plate, make and model. Later jobs can be linked to that car. "
            "The history endpoint returns previous roadside and booking records for that vehicle — the “service history log” "
            "from the concept paper.",
            s["body"],
        )
    )

    story.append(Paragraph("7.11 Read alerts", s["h2"]))
    story.append(
        Paragraph(
            "Profile → Notifications lists title, body and channel (push or sms). Use this in the demo to show "
            "that accept and complete events were recorded even when a real SMS gateway is not billed yet.",
            s["body"],
        )
    )

    story.append(Paragraph("7.12 Administrator (web, not the phone)", s["h2"]))
    story.append(
        Paragraph(
            "Open http://127.0.0.1:8000/admin/ with 256700000000 / admin123. Verify a new mechanic "
            "(is_verified = True) before they appear in nearby search. Inspect jobs, ratings, payments and OTP rows. "
            "This is the trust desk described in the concept paper.",
            s["body"],
        )
    )

    # 8
    story.append(Paragraph("8. Demo accounts and suggested walkthrough", s["h1"]))
    demo = [
        [Paragraph("Role", s["th"]), Paragraph("Phone", s["th"]), Paragraph("Password", s["th"]), Paragraph("Persona", s["th"])],
        [Paragraph("Owner", s["td"]), Paragraph("256700000001", s["td"]), Paragraph("pass123", s["td"]), Paragraph("Grace Namukasa, Toyota Corolla", s["td"])],
        [Paragraph("Mechanic", s["td"]), Paragraph("256700111001", s["td"]), Paragraph("pass123", s["td"]), Paragraph("Ronald, Wandegeya Garage", s["td"])],
        [Paragraph("Admin", s["td"]), Paragraph("256700000000", s["td"]), Paragraph("admin123", s["td"]), Paragraph("Platform operator", s["td"])],
    ]
    story.append(table(demo, [28 * mm, 40 * mm, 28 * mm, 66 * mm]))
    story.append(Paragraph("OTP demo code: 123456. Other seeded Kampala garages also use password pass123.", s["caption"]))
    story.append(
        Paragraph(
            "Suggested 3-minute demo: sign in as Grace → Find help → open Ronald → roadside request → "
            "switch user to Ronald → Accept → completed → switch back to Grace → rate → mark paid → show Notifications.",
            s["body"],
        )
    )

    # 9
    story.append(Paragraph("9. Repository map", s["h1"]))
    story.append(
        Paragraph(
            "<b>backend/</b> — Django project (config, accounts, mechanics, jobs, notifications), virtualenv, "
            "seed command <b>python manage.py seed_demo</b>.<br/>"
            "<b>mobile/mekafix/</b> — Flutter lib/ screens and state. After installing Flutter SDK, run "
            "<b>flutter create . --org com.mekafix --project-name mekafix --platforms android</b> then add "
            "INTERNET and location permissions.<br/>"
            "Flutter SDK folder on this machine: <b>C:\\flutter</b>. Android SDK: "
            "<b>C:\\Users\\hanes\\AppData\\Local\\Android\\Sdk</b>.",
            s["body"],
        )
    )

    story.append(Paragraph("10. What this means for the capstone story", s["h1"]))
    story.append(
        Paragraph(
            "Front end and back end are deliberately split so the phone stays usable on 3G/4G while the cloud "
            "owns trust (verification), ranking (distance and ratings), and records (jobs, history, payments). "
            "Users never “use the database”; they complete a short path: register → search → request or book → "
            "call → status updates → rate → optional pay. That path is the product, and REST is the joint that "
            "keeps Flutter and Django in sync.",
            s["body"],
        )
    )
    story.append(Spacer(1, 8 * mm))
    story.append(
        Paragraph(
            "End of document. Generated for MekaFix Group 7 from the implemented Django REST and Flutter codebase.",
            s["cover_sub"],
        )
    )

    doc = SimpleDocTemplate(
        str(OUT),
        pagesize=A4,
        leftMargin=18 * mm,
        rightMargin=18 * mm,
        topMargin=16 * mm,
        bottomMargin=16 * mm,
        title="MekaFix System Guide",
        author="MekaFix Group 7",
        subject="Front end, back end, connection and user tasks",
    )
    doc.build(story, onFirstPage=header_footer, onLaterPages=header_footer)
    return OUT


if __name__ == "__main__":
    path = build()
    print(path)
