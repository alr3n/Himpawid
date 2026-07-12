# Himpawid

**Real-time air quality monitoring, built with Flutter.**

Himpawid ("breath" in Filipino) shows the current and forecast US EPA Air Quality Index for your location, a live color-coded pollution map, city rankings, historical trends, and health guidance based on real, live data — no mock or placeholder data anywhere in the fetch pipeline.

<p>
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white">
  <img alt="Dart" src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white">
  <img alt="Firebase" src="https://img.shields.io/badge/Backend-Firebase-FFCA28?logo=firebase&logoColor=black">
  <img alt="Platforms" src="https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Web-informational">
  <img alt="License" src="https://img.shields.io/badge/License-Unspecified-lightgrey">
</p>

> Originally scaffolded with [FlutterFlow](https://flutterflow.io), then substantially rewritten by hand (custom map engine, live AQI pipeline, chatbot logic, and most page-level UI). This README documents the app **as it actually exists in code today**, not the original FlutterFlow template.

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Screenshots](#screenshots)
- [Tech Stack](#tech-stack)
- [APIs & Services](#apis--services)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Environment Variables](#environment-variables)
  - [Firebase Setup](#firebase-setup)
  - [Running the App](#running-the-app)
- [Application Workflow](#application-workflow)
- [Known Limitations](#known-limitations)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

Himpawid is a cross-platform (Android, iOS, Web) Flutter application that:

- Fetches the user's GPS location and computes a **real US EPA Air Quality Index (0–500, higher = worse)** from live PM2.5 data, not a vendor's proprietary scale.
- Renders a **full-viewport, continuously-tiled AQI heatmap** on top of a live map, colored by real sampled air quality data that follows you as you pan and zoom.
- Lets users search any place, save favourites, browse a world AQI ranking, view historical trends, and get condition-specific health advice.
- Sends and displays push notifications when new AQI readings come in.
- Includes a rule-based in-app assistant that answers air-quality questions using the same live data shown elsewhere in the app.
- Authenticates users via Firebase (email/password, Google, Apple) and persists their session and Firestore profile.

## Features

### 🔐 Authentication
- Email/password sign-in and sign-up, Google Sign-In, and Sign in with Apple (Apple is hidden on Android).
- Firebase Auth session persists across app restarts.
- `/profile` and `/editProfile` are route-guarded — a signed-out user (or a stale deep link) is redirected straight to `/login`.
- Logging out clears both the Firebase session and the native Google session, resets cached profile data immediately, and replaces the navigation stack so the back button can't return to authenticated pages.

### 🏠 Dashboard (Home)
- Live "current location" card with real-time AQI, EPA category (Good → Hazardous), and dominant pollutant.
- Per-pollutant breakdown grid: PM2.5, PM10, O₃, NO₂, SO₂, CO, NO, NH₃.
- AQI trend chart (`fl_chart`, past 7 days) on the dashboard, plus a dedicated full-screen forecast view offering 12h/24h/48h forward-looking ranges.
- Live preview cards for World Ranking, Favourites, Historical Insights, and Health Advice, each with its own loading/error/retry state.
- Educational blog articles (e.g. "What the AQI Colors Really Mean", mask/filtration guidance).

### 🗺️ Live AQI Map
- Full-screen map built on `flutter_map` with MapTiler raster tiles (dark `dataviz-dark` style).
- The AQI color wash is a **real, custom `TileProvider`** — each visible `(x, y, z)` tile is rendered on demand from live sampled AQI data, so the heatmap covers the entire viewport and new tiles load automatically as you pan or zoom, exactly like a professional pollution map.
- Adjacent tiles blend seamlessly because they draw from one shared, growing cache of real AQI samples (inverse-distance-weighted interpolation) rather than isolated per-tile data; already-sampled areas are never re-fetched, and concurrent API calls are throttled.
- A bottom summary card with an animated AQI gauge tracks whatever location the map is currently centered on in real time — not just the device's own location.

### 🌍 Explore Hub
- **World Ranking** — live AQI for a curated list of major world cities, sorted worst-first.
- **Favourites** — search any place by name (MapTiler geocoding), see its live AQI before saving, and manage a personal saved-locations list stored in Firestore.
- **Historical Insights** — daily-average AQI trend over the last 7 or 30 days, computed from OpenWeather's historical air pollution data, with average/min/max stats.
- **Health Advice** — condition-specific guidance (Asthma, Heart Issues, Allergies, Sinus, Cold/Flu, Chronic/COPD) with an educational-guidance disclaimer.

### 💬 Himpawid Assistant (Chatbot)
- A **rule-based** assistant (keyword matching, not an LLM) that answers questions about current AQI, individual pollutants, and safety recommendations (exercise, masks, opening windows), using the real EPA AQI scale and live data.
- Understands "in `<place>`" phrasing (e.g. *"what's the AQI in Manila?"*) and geocodes that place to answer with its real, live AQI instead of always answering for the device's own location.
- An unused `CHATBOT_API_KEY` exists in `.env` — see [Known Limitations](#known-limitations).

### 🔔 Notifications
- Every successful AQI fetch writes a Firestore `notifications` document, which a Cloud Function (`sendNotification`) picks up and pushes via FCM to registered device tokens.
- In-app notification feed reads the same Firestore collection live.
- Per-user notification preferences (push/email toggles) persisted to the user's Firestore document.

### 👤 Profile & Settings
- Profile page reflects the actual authenticated user in real time (display name, email, avatar) — see [Application Workflow](#application-workflow).
- Edit profile (display name, phone number; email is read-only, sourced from the auth provider).
- Language selection (English, Filipino, Cebuano fully wired; a larger ~40-locale picker exists in the UI but only these three are functional today — others show a "coming soon" message).
- Support (mailto), Terms of Service, Developer Info, and Invite Friends (copy-link) screens.

## Screenshots

<!--
Add screenshots here once available, e.g.:
| Dashboard | Live AQI Map | Explore Hub |
|---|---|---|
| ![Dashboard](docs/screenshots/dashboard.png) | ![Map](docs/screenshots/map.png) | ![Explore](docs/screenshots/explore.png) |

| Chatbot | Profile | Historical Insights |
|---|---|---|
| ![Chatbot](docs/screenshots/chatbot.png) | ![Profile](docs/screenshots/profile.png) | ![Historical](docs/screenshots/historical.png) |
-->

_Screenshots pending — add images under `docs/screenshots/` and link them here._

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart SDK `>=3.0.0 <4.0.0`) |
| Routing | `go_router`, with a `refreshListenable`-driven auth redirect |
| State management | `provider` + a global `FFAppState` (AQI/location/chart state) |
| Maps | `flutter_map`, `latlong2` — MapTiler raster tiles, custom tile-based AQI overlay |
| Backend | Firebase (Auth, Cloud Firestore, Cloud Messaging, Performance, Cloud Functions) |
| HTTP | `http`, `flutter_dotenv` for env-based API keys |
| Charts | `fl_chart` |
| Location | `geolocator`, `geocoding` |
| Animation | `flutter_animate`, `lottie` |
| Local persistence | `shared_preferences`, `sqflite` |
| Fonts/UI | `google_fonts`, `font_awesome_flutter`, `cached_network_image`, `smooth_page_indicator` |
| Misc | `url_launcher`, `permission_handler`, `timeago`, `rxdart` |

## APIs & Services

| Service | Used for | Notes |
|---|---|---|
| **MapTiler** | Map tile rendering (raster tiles) and forward/reverse geocoding | Replaced Google Maps Platform entirely — works with just an API key, no billing account required. Key: `MAPTILER_API_KEY`. |
| **OpenWeather Air Pollution API** | Live AQI data (current + historical), used everywhere in the app | The raw response's PM2.5 concentration is converted into a proper **US EPA AQI (0–500, higher = worse)** via the official Feb 2024 NAAQS breakpoints — OpenWeather's own coarse 1–5 index is not used directly. Key: `OPENWEATHER_API_KEY`. |
| **Firebase Authentication** | Email/password, Google, and Apple sign-in | Session persistence and route guarding, see [Features](#features). |
| **Cloud Firestore** | `users/{uid}` profile documents (favourites, notification prefs, display name), `notifications` feed | Security rules restrict `users/*` to the owning UID for all operations; see [Firebase Setup](#firebase-setup). |
| **Firebase Cloud Messaging** | Push notifications on new AQI readings | Device tokens are stored on the user's Firestore document; a Cloud Function broadcasts to all registered tokens on each new `notifications` document. |
| **Firebase Performance** | App performance monitoring | Initialized at app start; no custom traces added beyond the SDK default. |
| **Cloud Functions** | `sendNotification` (Firestore-triggered push), `onUserDeleted` (auth-triggered stub) | See `firebase/functions/index.js`. |

**Not currently integrated, despite appearances:** the `.env` file and Cloud Functions' `package.json` both reference AI/LLM-related config (a `CHATBOT_API_KEY` variable, and unused `langchain`/`google-genai` npm dependencies), but no code anywhere in `lib/` or `firebase/functions/` actually calls an AI API. The in-app chatbot is entirely rule-based. See [Known Limitations](#known-limitations).

## Project Structure

```
Himpawid/
├── lib/
│   ├── main.dart                    # App entry point, Firebase init, root MaterialApp.router
│   ├── app_state.dart                # FFAppState — global AQI/location/chart state
│   ├── auth/                         # Firebase Auth wiring
│   │   ├── firebase_auth/            # Email, Google, Apple sign-in; auth_util.dart (live user getters/streams)
│   │   └── base_auth_user_provider.dart
│   ├── backend/
│   │   ├── firebase/                  # Firebase initialization
│   │   └── schema/                    # Firestore document models (UsersRecord, etc.)
│   ├── custom_code/actions/           # Hand-written business logic (not FlutterFlow-generated UI):
│   │   ├── get_location_and_air_quality.dart   # GPS + reverse geocoding + AQI fetch, EPA AQI math
│   │   ├── fetch_aqi_forecast.dart              # Hourly forecast data
│   │   ├── fetch_aqi_history.dart               # Historical daily-average AQI
│   │   ├── fetch_city_rankings.dart             # World ranking data
│   │   ├── search_location.dart                 # MapTiler forward geocoding
│   │   ├── create_aqi_heatmap_overlay.dart      # The tile-based AQI heatmap TileProvider
│   │   └── generate_notification.dart           # Writes Firestore notification docs
│   ├── flutter_flow/
│   │   ├── nav/nav.dart               # go_router route table + auth guard logic
│   │   ├── flutter_flow_map.dart      # MapTiler-backed map widget wrapper
│   │   └── flutter_flow_theme.dart    # App theme/design tokens
│   ├── chat_bot/                      # Himpawid Assistant chat UI + rule-based reply logic
│   └── pages/                         # All app screens, one folder per page:
│       ├── login/                     # login, first_slide, welcome, getting_started
│       ├── homepage/                  # home_page (dashboard), blogs, chart_card, navigation
│       ├── heatmap/                   # Live AQI map page
│       ├── explore/                   # explore hub, ranking, favourites, historical, health_advice
│       ├── profile/                   # profile, edit_profile, language, developer_info
│       ├── notification/              # notification feed, notification_settings
│       └── location/, chart_full/     # location-permission gate, full-screen forecast chart
├── firebase/
│   ├── firestore.rules                # Security rules (see Firebase Setup)
│   ├── firestore.indexes.json
│   ├── firebase.json
│   └── functions/                     # Cloud Functions (Node.js): sendNotification, onUserDeleted
├── assets/                            # images/, jsons/ (Lottie animations), fonts/, etc.
├── logo/                              # App logo images (splash screen)
├── android/, ios/, web/               # Platform-specific projects/config
├── .env.example                       # Template for required environment variables
└── pubspec.yaml
```

> **Note on `lib/custom_code/` vs `lib/pages/`/`lib/flutter_flow/`:** this codebase still follows FlutterFlow's generated-project layout, but most of the actual application logic — the AQI fetch pipeline, the map engine, the chatbot, and most page UIs — has been hand-rewritten well beyond FlutterFlow's original scaffolding. `analysis_options.yaml` excludes `lib/custom_code/**` from static analysis (a FlutterFlow convention), which is why that folder in particular is worth reading directly rather than relying on the analyzer.

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel, Dart `>=3.0.0`)
- A Firebase project with **Authentication** (Email/Password, Google, Apple providers enabled), **Cloud Firestore**, and **Cloud Messaging** turned on
- API keys for:
  - [MapTiler](https://cloud.maptiler.com/account/keys/) (free tier is sufficient)
  - [OpenWeather](https://openweathermap.org/api) (Air Pollution API)

### Installation

```bash
git clone https://github.com/alr3n/Himpawid.git
cd Himpawid
flutter pub get
```

### Environment Variables

Copy `.env.example` to `.env` in the project root and fill in your keys:

```bash
cp .env.example .env
```

| Variable | Required | Purpose |
|---|---|---|
| `OPENWEATHER_API_KEY` | **Yes** | All AQI data (current, forecast, historical, rankings) fails without this. |
| `MAPTILER_API_KEY` | **Yes** | Map tiles, the AQI heatmap overlay, and all geocoding (search, reverse-geocoding place names) fail without this. |
| `CHATBOT_API_KEY` | No | Present in `.env.example` for forward-compatibility, but **no code currently reads this variable** — the chatbot is rule-based. Safe to leave blank. |

`.env` is bundled into the app binary as a Flutter asset (declared in `pubspec.yaml`) and is git-ignored — never commit real keys.

### Firebase Setup

1. Create a Firebase project and register your Android/iOS/Web apps.
2. Download `google-services.json` into `android/app/` and `GoogleService-Info.plist` into `ios/Runner/`.
3. Enable **Email/Password**, **Google**, and **Apple** sign-in providers under Authentication.
4. Deploy the included Firestore rules and Cloud Functions:
   ```bash
   cd firebase
   firebase deploy --only firestore:rules,functions
   ```
   The included `firestore.rules` restricts the `users/{uid}` collection so a user can only read/write their own document. The client also writes to a `notifications` collection (via `generate_notification.dart`) that isn't explicitly covered by the current rules file — see [Known Limitations](#known-limitations) if notifications aren't appearing.
5. Enable Cloud Messaging and, for web builds, configure a VAPID key if you intend to support web push.

### Running the App

```bash
flutter run                 # run on a connected device/emulator
flutter run -d chrome       # run in the browser
flutter build web           # production web build
flutter build apk           # production Android build
```

## Application Workflow

1. **Launch** — `main.dart` initializes Firebase and loads `.env`, then `go_router`'s initial route checks the live auth state: signed-in users land on the onboarding/dashboard flow, signed-out users land on `/login`.
2. **Login** — a user signs in with email/password, Google, or Apple. On first sign-in, a `users/{uid}` Firestore document is created from the auth provider's display name/email/photo.
3. **Dashboard** — the home page requests location permission, fetches GPS coordinates, reverse-geocodes them to a place name (MapTiler), and fetches live AQI (OpenWeather → EPA AQI conversion). Forecast, ranking, favourites, and historical preview cards load in parallel.
4. **Live AQI Map** — opening the map centers on the user's location and starts rendering the tile-based AQI color wash; panning/zooming loads new tiles and updates the bottom summary card with the AQI of wherever the map is currently centered.
5. **AQI Monitoring** — every successful AQI fetch updates `FFAppState`, writes a Firestore notification document, and (via a Cloud Function) triggers a push notification to the user's registered devices.
6. **Chatbot** — the assistant answers using the same live `FFAppState`/OpenWeather data, geocoding any place named in the question.
7. **Favourites** — searching a place shows its live AQI before saving; saved places are stored on the user's Firestore document and their AQI is refreshed on each visit.
8. **Historical Data** — the Historical Insights page fetches and aggregates OpenWeather's historical air pollution data into a daily-average trend chart.
9. **Profile** — reflects the authenticated user's real display name/email/photo in real time (updates immediately on sign-in/sign-out without needing to reopen the page); Edit Profile writes changes back to both Firebase Auth and the Firestore user document.
10. **Logout** — clears the Firebase session and the native Google session, resets cached profile state, and navigates to `/login` with the navigation stack cleared (the back button cannot return to authenticated pages).

## Known Limitations

Documented here in the interest of accuracy, per the codebase as it stands today:

- **No automated tests.** `test/widget_test.dart` exists but contains no assertions — there is currently no real test coverage.
- **Chatbot is rule-based, not AI-backed.** A `CHATBOT_API_KEY` exists in `.env`/`.env.example`, and the Cloud Functions `package.json` lists unused LangChain/Gemini dependencies, but nothing in the app actually calls an LLM.
- **"Forgot Password" is a non-functional stub** on the login screen (its button only logs to the console).
- **Language selection is partially implemented.** The language picker lists ~40 locales, but only English, Filipino, and Cebuano are functional; other selections show a "coming soon" message.
- **Firestore rules don't explicitly cover the `notifications` collection** that the app writes to — depending on your deployed rules, notification writes may be silently rejected (the write is wrapped in a try/catch that only logs the failure). Add an explicit rule for `notifications/{id}` if you deploy this yourself and notifications aren't appearing.
- **Push notifications broadcast to all registered device tokens**, not just the relevant user(s) — see `firebase/functions/index.js`.
- **`web/manifest.json` is referenced by `web/index.html` but does not exist** in the repository, which may affect PWA installability on web builds.
- Several `lib/pages/homepage/home_page_widget.dart`-adjacent files are empty leftover stubs from the original FlutterFlow scaffold and are not part of the active app (the real dashboard is `lib/pages/homepage/home_page/home_page_widget.dart`).

## Contributing

Issues and pull requests are welcome. Since this project has no automated test suite yet, please manually verify `flutter analyze` and `flutter build web` (or your target platform) succeed before submitting a PR, and describe what you tested.

## License

No license file is currently included in this repository. Contact the maintainer before reusing or redistributing this code.
