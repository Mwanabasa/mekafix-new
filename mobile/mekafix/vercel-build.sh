#!/usr/bin/env bash
set -euo pipefail

# Vercel does not provide Flutter as a built-in framework runtime.
# Install the stable Flutter SDK, then build the Flutter web target.
FLUTTER_HOME="$HOME/flutter-sdk"
if [ ! -x "$FLUTTER_HOME/bin/flutter" ]; then
  git clone --depth 1 --branch stable https://github.com/flutter/flutter.git "$FLUTTER_HOME"
fi
export PATH="$FLUTTER_HOME/bin:$PATH"

if [ -z "${API_BASE:-}" ]; then
  echo "ERROR: Set API_BASE in Vercel Environment Variables to your Render API origin, without /api."
  exit 1
fi

flutter config --enable-web
flutter pub get
flutter build web --release --dart-define=API_BASE="${API_BASE%/}"
