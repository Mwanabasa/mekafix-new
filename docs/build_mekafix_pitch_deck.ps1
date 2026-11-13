$ErrorActionPreference = "Stop"

function C([int]$r, [int]$g, [int]$b) { return $r + ($g * 256) + ($b * 65536) }

$teal      = C 11 110 79
$tealDark  = C 8 70 52
$ink       = C 16 35 28
$white     = C 255 255 255
$cream     = C 243 247 245
$amber     = C 244 162 97
$muted     = C 90 110 102
$card      = C 255 255 255
$softTeal  = C 220 236 229

$outPath = "C:\Users\hanes\OneDrive\Desktop\meka\docs\MekaFix_Pitch_Deck.pptx"
New-Item -ItemType Directory -Force -Path (Split-Path $outPath) | Out-Null

$ppt = New-Object -ComObject PowerPoint.Application
$ppt.Visible = 1
$pres = $ppt.Presentations.Add()
$pres.PageSetup.SlideWidth  = 960
$pres.PageSetup.SlideHeight = 540

function Add-Rect($slide, $x, $y, $w, $h, $color) {
  $s = $slide.Shapes.AddShape(1, $x, $y, $w, $h) # msoShapeRectangle
  $s.Fill.ForeColor.RGB = $color
  $s.Line.Visible = 0
  return $s
}

function Add-Round($slide, $x, $y, $w, $h, $color) {
  $s = $slide.Shapes.AddShape(5, $x, $y, $w, $h) # msoShapeRoundedRectangle
  $s.Fill.ForeColor.RGB = $color
  $s.Line.Visible = 0
  $s.Adjustments.Item(1) = 0.12
  return $s
}

function Add-Text($slide, $x, $y, $w, $h, $text, $size, $color, $bold=$false, $align=1) {
  $box = $slide.Shapes.AddTextbox(1, $x, $y, $w, $h)
  $tr = $box.TextFrame.TextRange
  $tr.Text = $text
  $tr.Font.Name = "Calibri"
  $tr.Font.Size = $size
  $tr.Font.Color.RGB = $color
  $tr.Font.Bold = $(if ($bold) { -1 } else { 0 })
  $box.TextFrame.WordWrap = -1
  $tr.ParagraphFormat.Alignment = $align # 1 left, 2 center, 3 right
  $box.TextFrame.MarginLeft = 6
  $box.TextFrame.MarginRight = 6
  $box.TextFrame.MarginTop = 2
  $box.TextFrame.MarginBottom = 2
  return $box
}

function New-Slide {
  $slide = $pres.Slides.Add($pres.Slides.Count + 1, 12) # ppLayoutBlank
  Add-Rect $slide 0 0 960 540 $cream | Out-Null
  Add-Rect $slide 0 0 960 8 $teal | Out-Null
  Add-Rect $slide 0 520 960 20 $tealDark | Out-Null
  Add-Text $slide 24 518 500 20 "MekaFix  |  Group 7 Capstone  |  Confidential demo deck" 10 $white $false 1 | Out-Null
  Add-Text $slide 700 518 236 20 "Connecting drivers to verified mechanics" 10 $white $false 3 | Out-Null
  return $slide
}

function Add-Card($slide, $x, $y, $w, $h, $title, $body) {
  Add-Round $slide $x $y $w $h $white | Out-Null
  Add-Rect $slide $x $y 8 $h $teal | Out-Null
  Add-Text $slide ($x+20) ($y+12) ($w-32) 28 $title 16 $teal $true | Out-Null
  Add-Text $slide ($x+20) ($y+42) ($w-32) ($h-54) $body 13 $ink $false | Out-Null
}

# --- 1 Title ---
$s = $pres.Slides.Add(1, 12)
Add-Rect $s 0 0 960 540 $tealDark | Out-Null
Add-Rect $s 0 0 18 540 $amber | Out-Null
Add-Text $s 60 70 840 36 "GROUP 7  ·  SEMESTER CAPSTONE" 14 $amber $true | Out-Null
Add-Text $s 60 120 860 80 "MekaFix" 54 $white $true | Out-Null
Add-Text $s 60 200 820 70 "A mobile app that connects vehicle owners with verified nearby mechanics and real-time roadside assistance." 20 $cream $false | Out-Null
Add-Text $s 60 310 820 90 "Problem  ·  Solution  ·  Product features  ·  How the owners make money" 18 $white $false | Out-Null
Add-Text $s 60 430 820 50 "Mpanga Marvin Joseph  ·  Mwanabasa Hanes  ·  Kedi PeterPaul`rKampala  ·  Makerere / Wandegeya corridor" 14 $cream $false | Out-Null

# --- 2 Agenda ---
$s = New-Slide
Add-Text $s 48 28 860 40 "What this deck covers" 28 $ink $true | Out-Null
$items = @(
  @("01", "The problem", "Why drivers and small garages in Kampala still struggle to find each other."),
  @("02", "The solution", "How MekaFix matches, verifies, and coordinates help on a phone."),
  @("03", "Product features", "What owners, mechanics, and admins can do in the app today."),
  @("04", "How we make money", "Commission, featured listings, subscriptions, and later ads — as the app owners.")
)
$y = 90
foreach ($it in $items) {
  Add-Round $s 48 $y 864 90 $white | Out-Null
  Add-Text $s 70 ($y+18) 70 54 $it[0] 26 $teal $true | Out-Null
  Add-Text $s 150 ($y+16) 730 30 $it[1] 18 $ink $true | Out-Null
  Add-Text $s 150 ($y+46) 730 34 $it[2] 14 $muted $false | Out-Null
  $y += 102
}

# --- 3 Problem ---
$s = New-Slide
Add-Text $s 48 24 860 36 "The problem statement" 28 $ink $true | Out-Null
Add-Text $s 48 66 860 40 "Vehicle owners cannot reliably find a nearby, trustworthy mechanic when a car fails — especially away from their usual garage." 16 $ink $false | Out-Null
Add-Card $s 48 120 280 360 "For drivers" "Breakdowns happen in unfamiliar places. People ask boda riders, call friends, or walk away from the car. They do not know who is near, what it will cost, or whether the garage is trustworthy. Delay and biased directions are common."
Add-Card $s 340 120 280 360 "For mechanics" "Independent garages and roadside helpers struggle to reach new customers beyond walk-ins and WhatsApp. They lack a simple way to manage requests, quotes, availability, and vehicle history."
Add-Card $s 632 120 280 360 "The gap" "There is no widely used local platform that combines GPS search, verification, estimates, booking, roadside location share, and ratings — with a fallback when mobile data is weak."

# --- 4 Today ---
$s = New-Slide
Add-Text $s 48 24 860 36 "What people do today" 28 $ink $true | Out-Null
Add-Text $s 48 68 860 32 "Field work around Makerere, Wandegeya and Kampala showed a pattern — not a lack of mechanics, a lack of a trusted match." 15 $muted $false | Out-Null
$rows = @(
  @("Ask a passerby or boda", "Fast, but directions and recommendations are often biased or unclear."),
  @("Phone, SMS, WhatsApp", "Works if you already know someone. Useless if you are new to the area."),
  @("Walk away from the car", "Risky. The vehicle is left on the roadside while the driver searches."),
  @("Show up at a random garage", "No ratings, no estimate up front, no record of what was done.")
)
$y = 120
foreach ($r in $rows) {
  Add-Round $s 48 $y 864 88 $white | Out-Null
  Add-Rect $s 48 $y 10 88 $amber | Out-Null
  Add-Text $s 78 ($y+14) 800 28 $r[0] 18 $ink $true | Out-Null
  Add-Text $s 78 ($y+46) 800 32 $r[1] 14 $muted $false | Out-Null
  $y += 96
}

# --- 5 Solution ---
$s = New-Slide
Add-Text $s 48 24 860 36 "The solution: MekaFix" 28 $ink $true | Out-Null
Add-Text $s 48 68 860 50 "A Flutter mobile app plus a Django cloud API that uses GPS, verification, ratings and mobile money to connect drivers with nearby mechanics — without rewriting the product for iOS later." 16 $ink $false | Out-Null
Add-Card $s 48 140 430 160 "For the driver" "Open the app, see verified garages sorted by distance and rating, share live location for roadside help, book a non-emergency job, call the mechanic, then rate and pay."
Add-Card $s 492 140 420 160 "For the mechanic" "Appear in nearby search when available, receive requests with the customer’s location and phone, accept, update job status, and grow a public reputation."
Add-Card $s 48 318 430 160 "For trust" "Admins verify mechanics before they rank in search. Transparent price ranges and accumulated ratings replace guesswork."
Add-Card $s 492 318 420 160 "For Kampala realities" "Works on Android first. Offline cache of last nearby list. SMS-style fallback for critical alerts when data drops."

# --- 6 How it works ---
$s = New-Slide
Add-Text $s 48 24 860 36 "How a job actually runs" 28 $ink $true | Out-Null
$steps = @(
  @("1", "Sign in", "Phone number login. Owner, mechanic, or admin."),
  @("2", "Find help", "GPS search by distance, rating, service and price range."),
  @("3", "Request", "Roadside with live location, or a booked appointment."),
  @("4", "Accept", "Mechanic accepts. Owner is notified and can tap to call."),
  @("5", "Do the work", "Status: on the way → in progress → completed."),
  @("6", "Close", "Owner rates the job and marks mobile-money payment.")
)
$cols = 3
$i = 0
foreach ($st in $steps) {
  $col = $i % $cols
  $row = [int][Math]::Floor($i / $cols)
  $x = 48 + ($col * 300)
  $y = 90 + ($row * 200)
  Add-Round $s $x $y 284 180 $white | Out-Null
  Add-Text $s ($x+18) ($y+16) 60 40 $st[0] 28 $teal $true | Out-Null
  Add-Text $s ($x+18) ($y+64) 248 36 $st[1] 18 $ink $true | Out-Null
  Add-Text $s ($x+18) ($y+104) 248 60 $st[2] 14 $muted $false | Out-Null
  $i++
}

# --- 7 Features owners ---
$s = New-Slide
Add-Text $s 48 24 860 36 "Features for vehicle owners" 28 $ink $true | Out-Null
$feats = @(
  @("Phone registration and login", "Must-have"),
  @("Nearby mechanic search (GPS, rating, distance, estimate)", "Must-have"),
  @("Roadside assistance with live location share", "Must-have"),
  @("Appointment booking for non-emergency jobs", "Must-have"),
  @("Push / SMS-style alerts (accepted, reminders, status)", "Must-have"),
  @("Ratings and reviews after the job", "Must-have"),
  @("Tap-to-call the mechanic (no heavy live chat required)", "Must-have"),
  @("Vehicle log and service history", "Built"),
  @("Offline cache of last nearby mechanics + queued ratings", "Built"),
  @("Mobile-money sandbox payment (mark as paid)", "Built")
)
$y = 78
$left = $true
foreach ($f in $feats) {
  $x = if ($left) { 48 } else { 504 }
  Add-Round $s $x $y 408 72 $white | Out-Null
  Add-Text $s ($x+16) ($y+8) 280 56 $f[0] 14 $ink $true | Out-Null
  Add-Text $s ($x+300) ($y+20) 92 32 $f[1] 11 $teal $true 3 | Out-Null
  if (-not $left) { $y += 82 }
  $left = -not $left
}

# --- 8 Features mechanics ---
$s = New-Slide
Add-Text $s 48 24 860 36 "Features for mechanics and the platform" 28 $ink $true | Out-Null
Add-Card $s 48 90 430 390 "Mechanic / garage app" "• Incoming roadside and booking inbox`r• Accept a job and take the customer`r• Update: en route, in progress, completed`r• Go available at current GPS so they appear in nearby search`r• Public rating that grows with completed work`r• Call the driver from the job card`r• Garage profile: services, area, price range"
Add-Card $s 492 90 420 390 "Admin and cloud" "• Verify mechanics before they rank in search`r• Manage users, complaints and job records`r• REST API over HTTPS (Django)`r• Notification log for push and SMS fallback`r• Sandbox mobile money, ready to swap for live MoMo`r• Architecture ready for PostgreSQL in production`r• Android-first Flutter; iOS is the same codebase later"

# --- 9 Money overview ---
$s = New-Slide
Add-Text $s 48 24 860 36 "How we make money as the owners" 28 $ink $true | Out-Null
Add-Text $s 48 68 860 50 "Drivers stay free. We earn from the marketplace around completed work and garage visibility — not from locking people out of a phone call." 16 $ink $false | Out-Null
Add-Card $s 48 130 430 170 "Principle" "The person in a breakdown will not pay a subscription to open the app. Independent garages will pay for customers and placement. So owners of MekaFix charge the supply side and take a small cut of successful jobs."
Add-Card $s 492 130 420 170 "When cash starts" "Featured listings can be invoiced on mobile money even before live checkout. Commission needs completed jobs and real MoMo. Ads and fleet deals come after we have usage."
Add-Round $s 48 320 864 170 $teal | Out-Null
Add-Text $s 70 340 820 36 "Owner takeaway" 18 $amber $true | Out-Null
Add-Text $s 70 380 820 80 "We own the match, the verification, and the job record. That is what we monetise: a fee when a job is done, a fee to be seen first, and later a fee for extra tools and advertising." 16 $white $false | Out-Null

# --- 10 Revenue streams ---
$s = New-Slide
Add-Text $s 48 20 860 34 "Revenue streams" 28 $ink $true | Out-Null
$rev = @(
  @("1. Job commission", "5–10% of the amount paid through the app when a job is completed. Example: UGX 80,000 roadside job → UGX 4,000–8,000 to MekaFix. Taken only on finished, paid work — not on every request."),
  @("2. Featured listings", "Garages pay monthly to sit higher in nearby search. Easiest early money. Pilot: first month free if they refer another garage. Starter price band: UGX 50,000–150,000 / month."),
  @("3. Mechanic subscriptions", "Free basic account (requests + ratings). Paid plan: extra visibility, analytics, availability boost. Small workshops understand a monthly fee."),
  @("4. Ads (later)", "Spare-parts dealers, insurance and oil brands pay for placements. Only after we have real traffic, and never on the emergency request screen."),
  @("5. Fleet packages (later)", "Taxi, boda and company fleets pay for many vehicles, service reminders, history and one bill. Higher value than a single private car owner.")
)
$y = 62
foreach ($r in $rev) {
  Add-Round $s 48 $y 864 82 $white | Out-Null
  Add-Text $s 66 ($y+8) 820 24 $r[0] 15 $teal $true | Out-Null
  Add-Text $s 66 ($y+34) 820 42 $r[1] 12 $ink $false | Out-Null
  $y += 88
}

# --- 11 Numbers ---
$s = New-Slide
Add-Text $s 48 24 860 36 "What that can look like" 28 $ink $true | Out-Null
Add-Text $s 48 68 860 40 "Illustrative, not a promise — using the Kampala corridor numbers from the concept paper." 14 $muted $false | Out-Null
Add-Round $s 48 120 284 250 $white | Out-Null
Add-Text $s 68 140 244 40 "Market focus" 16 $teal $true | Out-Null
Add-Text $s 68 186 244 160 "Kampala metro: hundreds of thousands of vehicles. Year-1 aim in the paper: 3,600–6,000 active drivers and 150–200 verified mechanics in the Makerere–Wandegeya corridor." 13 $ink $false | Out-Null
Add-Round $s 348 120 284 250 $white | Out-Null
Add-Text $s 368 140 244 40 "Commission example" 16 $teal $true | Out-Null
Add-Text $s 368 186 244 160 "If 50 jobs/week close at UGX 60,000 average and we take 8%, that is about UGX 1.2 million/week before SMS, hosting and MoMo fees. Volume has to exist first." 13 $ink $false | Out-Null
Add-Round $s 648 120 264 250 $white | Out-Null
Add-Text $s 668 140 224 40 "Near-term cash" 16 $teal $true | Out-Null
Add-Text $s 668 186 224 160 "10 featured garages at UGX 80,000/month is UGX 800,000/month with no live payment gateway required — we collect on MoMo to the business number." 13 $ink $false | Out-Null
Add-Round $s 48 388 864 110 $softTeal | Out-Null
Add-Text $s 68 404 824 80 "Costs we must cover as owners: hosting, SMS gateway, mobile-money fees, verification time, and Play Store listing. Commission and listings should stay wide enough to fund that and still leave the mechanic better off than Facebook ads." 14 $ink $false | Out-Null

# --- 12 Path ---
$s = New-Slide
Add-Text $s 48 24 860 36 "How we start collecting" 28 $ink $true | Out-Null
$phases = @(
  @("Now", "Keep the sandbox pay button in the app. Invoice 2–3 pilot garages by hand for featured placement. Spreadsheet + MoMo to the team."),
  @("Next", "Turn on live mobile money. Take commission only on completed jobs. Publish a one-page mechanic pricing sheet."),
  @("Then", "Launch a paid mechanic plan and featured search slots in the product itself, not only on paper."),
  @("Later", "Ads and fleet contracts once weekly jobs and ratings are real enough that brands want the audience.")
)
$x = 48
foreach ($p in $phases) {
  Add-Round $s $x 100 210 360 $white | Out-Null
  Add-Rect $s $x 100 210 10 $amber | Out-Null
  Add-Text $s ($x+16) 128 178 40 $p[0] 20 $teal $true | Out-Null
  Add-Text $s ($x+16) 180 178 250 $p[1] 14 $ink $false | Out-Null
  $x += 226
}

# --- 13 Close ---
$s = $pres.Slides.Add($pres.Slides.Count + 1, 12)
Add-Rect $s 0 0 960 540 $tealDark | Out-Null
Add-Rect $s 0 0 18 540 $amber | Out-Null
Add-Text $s 60 80 840 40 "MekaFix" 40 $white $true | Out-Null
Add-Text $s 60 150 840 80 "Trusted nearby help for drivers.`rA fair pipeline of jobs for verified mechanics.`rA marketplace we own and can charge for." 20 $cream $false | Out-Null
Add-Text $s 60 280 840 70 "Demo: owner 256700000001 / pass123   ·   mechanic 256700111001 / pass123`rAdmin site: /admin  ·  256700000000 / admin123" 16 $white $false | Out-Null
Add-Text $s 60 400 840 50 "Thank you  ·  Questions" 24 $amber $true | Out-Null

if (Test-Path $outPath) { Remove-Item $outPath -Force }
$ppSaveAsOpenXMLPresentation = 24
$pres.SaveAs($outPath, $ppSaveAsOpenXMLPresentation)
$pres.Close()
$ppt.Quit()
[System.Runtime.InteropServices.Marshal]::ReleaseComObject($pres) | Out-Null
[System.Runtime.InteropServices.Marshal]::ReleaseComObject($ppt) | Out-Null
[GC]::Collect()
Write-Output "SAVED $outPath"
