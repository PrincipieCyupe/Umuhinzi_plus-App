# Umuhinzi Plus — Agricultural Mobile Application

A Flutter mobile application empowering Rwandan farmers with real-time market prices, farming tips, weather forecasts, and personalized crop guidance. Built with Clean Architecture, BLoC state management, and a Firebase backend.

**GitHub Repository:** https://github.com/PrincipieCyupe/Umuhinzi_plus-App

---

## Table of Contents
1. [App Overview](#app-overview)
2. [Setup Instructions](#setup-instructions)
3. [Architecture](#architecture)
4. [Database Architecture](#database-architecture)
5. [Implemented Functionalities](#implemented-functionalities)
6. [Authentication](#authentication)
7. [State Management](#state-management)
8. [Firebase Security Rules](#firebase-security-rules)
9. [SharedPreferences / User Preferences](#sharedpreferences--user-preferences)
10. [Testing](#testing)
11. [Known Limitations and Future Work](#known-limitations-and-future-work)
12. [Screenshots](#screenshots)
13. [Flutter Analyze](#flutter-analyze)
    

---

## App Overview

**Umuhinzi Plus** (*Umuhinzi* = "Farmer" in Kinyarwanda) is a mobile-first app for Rwandan smallholder farmers. It aggregates:

- Live market produce prices from Firestore (user-contributed) and WFP Rwanda food price data
- Weather forecasts by district via OpenWeatherMap (RapidAPI)
- Curated farming tips and YouTube video tutorials
- Personalized onboarding based on crop, season, province, and district

**Target platforms:** Android (primary), Web (secondary).

---

## Setup Instructions

### Prerequisites

| Tool | Version |
|------|---------|
| Flutter SDK | ≥ 3.10.4 |
| Dart SDK | ≥ 3.10.4 |
| Android Studio / VS Code | Latest stable |
| Firebase CLI | Latest (`npm install -g firebase-tools`) |
| Java (for Android build) | 17+ |

### 1. Clone the Repository
```bash
git clone https://github.com/PrincipieCyupe/Umuhinzi_plus-App.git
cd umuhinzi_plus
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Firebase Configuration
`lib/firebase_options.dart` is pre-configured for the project. No additional setup is required to run the app.

To connect to your own Firebase project:
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```
Enable in your Firebase console: **Authentication** (Email/Password + Google), **Cloud Firestore** (production mode).

### 4. Run the App
```bash
flutter run                        # connected device/emulator
flutter run -d <device_id>        # specific device
flutter devices                   # list available devices
```

### 5. Build a Release APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### 6. Run Tests
```bash
flutter test                  # all tests
flutter test --coverage       # with coverage report
```

### 7. Regenerate Mocks (if needed)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Architecture

The app follows **Flutter Clean Architecture** with feature-based folder organization:

```
lib/
├── core/
│   ├── config/          # API keys and configuration constants
│   ├── constants/       # Rwanda geographic data (provinces, districts)
│   ├── error/           # Failure types for Either<Failure, T> pattern
│   └── utils/           # Page transition animations (FadeRoute, SlideUpRoute,
│                        #   SlideRightRoute)
└── features/
    ├── home/            # Auth screens, onboarding, weather BLoC, navigation
    │   ├── data/        # WeatherRepository, LocalStorageService, WeatherService
    │   │                #   (WeatherModel handles Kelvin→Celsius conversion)
    │   ├── domain/      # WeatherEntity
    │   ├── presentation/# AuthCubit, HomeCubit, WeatherBloc, InputDetailsBloc,
    │   │                #   NavigationCubit
    │   ├── screens/     # Login, Signup, ForgotPassword, EmailVerification,
    │   │                #   Welcome (3-step), InputDetails, HomeScreen
    │   └── service/     # AuthService (Firebase Auth wrapper)
    ├── market/          # Market produce prices
    │   ├── data/        # MarketRemoteDataSource, MarketCsvDataSource,
    │   │                #   MarketPriceFirestoreSource, WfpPriceDataSource,
    │   │                #   PreferencesService
    │   ├── domain/      # ProduceEntity, use cases (AddProduce, DeleteProduce,
    │   │                #   UpdateProduce, GetProduceByCategory, SearchProduce)
    │   └── presentation/# MarketBloc, MarketPriceCubit, widgets, MarketPage
    ├── tips/            # Farming tips and YouTube videos
    │   ├── data/        # TipsLocalDataSource, TipsFirestoreDataSource,
    │   │                #   YoutubeDataSource
    │   ├── domain/      # TipEntity, GetTips use case
    │   └── presentation/# TipsBloc, TipsPage, ArticleReaderPage, VideoPlayerPage
    └── weather/         # WeatherPage UI
```

### Layer Responsibilities

| Layer | Responsibility |
|-------|---------------|
| Presentation | UI widgets, BLoC/Cubit event dispatch, state rendering |
| Domain | Business entities, use-case classes, repository interfaces |
| Data | Repository implementations, remote/local data sources, model serialization |

---

## Database Architecture

### Entity-Relationship Overview

```
┌──────────────────────────────────────────────┐
│            Firebase Authentication            │
│  uid (PK) | email | displayName | provider   │
└────────────────────┬─────────────────────────┘
                     │ owns (via uid)
          ┌──────────▼──────────────┐
          │   SharedPreferences     │
          │  (local, per device)    │
          │  user_name              │
          │  selected_crop          │
          │  selected_season        │
          │  selected_province      │
          │  selected_district (FK) │
          └─────────────────────────┘

Firestore Collections:

┌──────────────────────────────────────────────┐
│         market_produce  (Collection)          │
│  id: auto-generated (PK)                     │
│  name:        String    — produce name        │
│  price:       Double    — price in RWF        │
│  unit:        String    — kg / head / bunch   │
│  category:    String    — vegetables/fruits/  │
│                            grains/livestock   │
│  imageUrl:    String    — CDN image URL       │
│  isAvailable: Boolean   — in-stock flag       │
│  updatedAt:   Timestamp — last modified       │
└──────────────────────────────────────────────┘

┌──────────────────────────────────────────────┐
│         tips  (Collection)                    │
│  id: custom (e.g. "1", "2") (PK)            │
│  title:       String    — tip headline        │
│  description: String    — short summary       │
│  body:        String    — full article text   │
│  imageUrl:    String    — cover image URL     │
│  category:    String    — Article/Post/Video  │
│  videoId:     String?   — YouTube video ID    │
│  date:        String    — ISO8601 date        │
└──────────────────────────────────────────────┘

┌──────────────────────────────────────────────┐
│         market_prices  (Collection)           │
│  id: {commodity}_{market}_{date} (PK)        │
│  commodity:   String    — crop name           │
│  market:      String    — market location     │
│  district:    String    — admin district (FK) │
│  price:       Double    — price in RWF        │
│  unit:        String    — measurement unit    │
│  date:        String    — YYYY-MM-DD          │
│  priceType:   String    — retail / wholesale  │
│  fetchedAt:   Timestamp — sync timestamp      │
└──────────────────────────────────────────────┘
```

### Relationships
- `market_prices.district` references the user's `selected_district` in SharedPreferences to filter relevant prices
- `market_produce` documents support full CRUD via the app UI
- `market_prices` documents are ingested automatically from the WFP Rwanda food prices CSV; Firestore writes are restricted at the security rule level

### Indexes

| Collection | Field | Order | Purpose |
|------------|-------|-------|---------|
| market_produce | category | — | Filter by category |
| market_produce | name | Ascending | Prefix search |
| market_prices | district | — | Location filter |
| market_prices | date | Descending | Latest prices first |

---

## Implemented Functionalities

### Onboarding
- 3-step welcome screens (`FirstScreen` → `SecondScreen` → `ThirdScreen`)
- Farm profile setup: crop, season, province, district (selecting a province dynamically loads its districts)
- Profile persisted to SharedPreferences via `InputDetailsBloc`; pre-fills on return

### Authentication
- Email/password registration with input validation and **email verification gate** — users cannot access the app until their email is verified; unverified users are redirected to `EmailVerificationScreen` on both signup and login
- Email/password login
- Google Sign-In (Google-authenticated users bypass the email verification gate)
- Password reset via email link
- Logout clears both Firebase and Google sessions
- Auth state persisted across app restarts via `FirebaseAuth.authStateChanges()` stream in `AuthWrapper` (`main.dart`)

### Market — Full CRUD

| Operation | Trigger | Firestore Action |
|-----------|---------|-----------------|
| Create | "Add Produce" form | `collection.add(doc)` |
| Read | App launch / category tab | `collection.where().snapshots()` stream |
| Update | Edit dialog on produce card | `doc.update(fields)` |
| Delete | Swipe or delete button | `doc.delete()` |

- Real-time category filtering via `MarketBloc` using `emit.forEach()` on repository streams
- Debounced prefix search (300 ms via RxDart `debounceTime` + `switchMap`)

### Market Prices (WFP Data)
- Background sync of WFP Rwanda food price CSV on app startup (`_preloadMarketData()` in `main.dart`)
- 30-minute periodic refresh via `MarketPriceCubit` timer
- Deduplication by compound key `{commodity}_{market}` keeping the most recent date
- District-filtered price display via filter chips (All, Kigali, Eastern, Northern, Southern, Western)

### Weather
- Current weather by district using RapidAPI OpenWeather 5-day forecast endpoint
- Kelvin-to-Celsius conversion handled in `WeatherModel._kelvinToCelsius()`
- Fetch by district name (mapped to coordinates via `RwandaDistricts`) or direct GPS coordinates
- `WeatherBloc` manages `WeatherInitial / WeatherLoading / WeatherLoaded / WeatherError` states
- Weather pre-fetched for the user's saved district on `HomeContent.initState()`

### Farming Tips
- Tips sourced from Firestore (Articles and Posts); seeded automatically on first launch from local hardcoded data if the Firestore `tips` collection is empty
- YouTube videos fetched via YouTube Data API v3; falls back to hardcoded local video list on failure
- Categorized tips with full article reader (`ArticleReaderPage`) and embedded YouTube player (`VideoPlayerPage` using `youtube_player_flutter`)
- Search and category filter (All / Post / Video / Article) managed by `TipsBloc`

### Navigation
- Bottom navigation bar (Home, Weather, Market, Tips) via `NavigationCubit`
- Custom page transitions: `FadeRoute`, `SlideUpRoute`, `SlideRightRoute`
- Drawer with farm summary card, profile update shortcut, weather tab shortcut, and sign-out confirmation dialog
- Auth-gated routing via `StreamBuilder<User?>` on `authStateChanges()` in `AuthWrapper`

---

## Authentication

### Method 1: Email / Password
```
Register → validate inputs → Firebase createUserWithEmailAndPassword()
         → sendEmailVerification() → redirect to EmailVerificationScreen
         → user taps "I've Verified — Continue" → reloadAndCheckVerified()
         → if verified → navigate to Home or InputDetails

Login    → validate → Firebase signInWithEmailAndPassword()
         → if !emailVerified → redirect to EmailVerificationScreen
         → if verified → navigate to Home or InputDetails

Reset    → Firebase sendPasswordResetEmail()
```

**Validation rules (login):**
- Email: `^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$`
- Password: minimum 6 characters

**Additional validation on signup:**
- Password must contain at least one uppercase letter, one lowercase letter, and one digit
- Confirm password field must match password

**12 Firebase Auth error codes** mapped to user-friendly messages in `AuthService._handleAuthException()`: `user-not-found`, `wrong-password`, `email-already-in-use`, `invalid-email`, `weak-password`, `user-disabled`, `too-many-requests`, `network-request-failed`, `popup-closed-by-user`, `account-exists-with-different-credential`, `operation-not-allowed`, `invalid-credential`.

### Method 2: Google Sign-In
- **Mobile:** `GoogleSignIn.instance.authenticate()` → `OAuthCredential` → `Firebase signInWithCredential()`
- **Web:** `GoogleAuthProvider` → `Firebase signInWithPopup()`
- Google Sign-In users are considered pre-verified and skip the email verification gate
- Sign-out clears both Firebase and Google sessions

---

## State Management

All features use **BLoC / Cubit** from `flutter_bloc ^8.1.3`. Business logic never sits inside widgets.

| BLoC / Cubit | Feature | Pattern |
|-------------|---------|---------|
| AuthCubit | Authentication | Emits `AuthLoading / AuthSuccess / AuthError / AuthEmailUnverified / AuthVerificationSent / PasswordResetSent` |
| HomeCubit | Home tab data | Loads user profile from SharedPreferences + Firebase; category selection state |
| WeatherBloc | Weather data | Repository + use-case injection; `try/catch` emit pattern |
| InputDetailsBloc | Farm profile | Form validation + province-cascade district loading + SharedPrefs persistence |
| MarketBloc | Market produce | `emit.forEach()` on repository streams; RxDart debounce on search events |
| MarketPriceCubit | WFP prices | Periodic sync timer + stream filtering by district / category / search |
| TipsBloc | Tips / videos | In-memory filter across `_allTips`; category and search state |
| NavigationCubit | Bottom nav | Tab index state |

`Either<Failure, T>` from `dartz` is used across all `MarketRepository` interfaces for explicit, testable error propagation.

---

## Firebase Security Rules

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Market produce: read/write for authenticated users
    match /market_produce/{produceId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null;
    }

    // Market prices: read-only; writes via server-side sync only
    match /market_prices/{priceId} {
      allow read: if request.auth != null;
      allow write: if false;
    }

    // Tips: read-only; admin-managed from Firebase console
    match /tips/{tipId} {
      allow read: if request.auth != null;
      allow write: if false;
    }
  }
}
```

**How these rules protect data:**
- All Firestore access requires an authenticated Firebase user, preventing anonymous reads/writes
- `market_prices` is write-protected at the rule level — only the WFP batch sync can populate it; end users cannot modify price data
- `tips` are admin-managed only; end users have read-only access
- **Planned improvement:** restrict `market_produce` updates/deletes to the document creator by storing a `createdBy: uid` field and checking `request.auth.uid == resource.data.createdBy`

---

## SharedPreferences / User Preferences

| Key | Type | Feature | Restored On |
|-----|------|---------|-------------|
| `user_name` | String | Profile | App launch |
| `user_email` | String | Profile | App launch |
| `selected_crop` | String | Onboarding | Home screen |
| `selected_season` | String | Onboarding | Home screen |
| `selected_province` | String | Onboarding | Input screen |
| `selected_district` | String | Onboarding | Weather + Market filter |
| `is_onboarding_complete` | Bool | Routing | Auth wrapper |
| `language` | String | Localization | App theme |
| `last_selected_category` | String | Market | Market page (default: `All`) |
| `preferred_currency` | String | Market | Market page (default: `RWF`) |
| `last_search_query` | String | Market | Market page |

Preferences are initialized via `FutureBuilder<SharedPreferences>` in `home_screen.dart` before any UI renders, ensuring values are always available on first frame.

---

## Testing

### Test Files

| File | Type | What it Tests |
|------|------|--------------|
| `auth_service_test.dart` | Unit | Email validation regex (8 cases) |
| `login_screen_test.dart` | Widget | Login form rendering and interactions |
| `forgot_password_screen_test.dart` | Widget | Password reset form |
| `search_produce_test.dart` | Unit | SearchProduce use case with mocks |
| `get_produce_by_category_test.dart` | Unit | Category filtering use case |
| `market_repository_impl_test.dart` | Unit | Repository stream error/success handling |
| `market_price_filter_test.dart` | Unit | Price filtering logic via `filterPricesForTest()` |
| `produce_card_test.dart` | Widget | ProduceCard widget rendering |
| `widget_test.dart` | Widget | General app widget smoke test |

### Running Tests
```bash
flutter test                  # all tests
flutter test --coverage       # with coverage report
```

Screenshots of test results and coverage report are included in the PDF report.

---

## Known Limitations and Future Work

### Known Limitations
- **iOS not configured** — `firebase_options.dart` targets Android and Web only; iOS requires adding an iOS Firebase app and re-running `flutterfire configure`
- **Tips write access** — farming tips are seeded from hardcoded local data; there is no in-app admin UI to add or modify tips (Firebase console only)
- **WFP sync requires internet on first launch** — market prices will be empty offline until connectivity is restored; Firestore offline persistence is not yet enabled
- **Weather API key is public** — the RapidAPI OpenWeatherMap key is bundled in the binary; should be moved to a Cloud Function or Firebase Remote Config for production
- **Market produce images** — image URLs are user-supplied strings with no validation; a malformed URL shows a fallback icon via `CachedNetworkImage`'s `errorWidget`
- **`market_produce` ownership not enforced** — any authenticated user can update or delete any produce entry; the `createdBy` field is not yet stored or checked

### Future Work
- Admin role (via Firebase Auth custom claims) for tip CRUD within the app
- iOS support and physical device testing
- Push notifications via Firebase Cloud Messaging for significant price changes and weather alerts
- Firestore offline persistence (`FirebaseFirestore.instance.settings`) for previously fetched produce prices
- Full Kinyarwanda (`rw`) and French (`fr`) localization using Flutter's `intl` package and ARB files; the `language` preference key is already stored
- `createdBy` field on `market_produce` for ownership-restricted edit/delete security rules
- On-device crop disease detection using a TensorFlow Lite model

---

## Screenshots

| Screen | Description |
|--------|-------------|
| Login | Login screen with email/password and Google Sign-In |
| Signup | Registration with name, email, password, confirm password, and Terms checkbox |
| Email Verification | Frosted-glass verification screen with "I've Verified" and resend buttons |
| Home | Home tab with weather summary, market preview, and category grid |
| Market | WFP live prices with district filter chips and category tabs |
| Tips | Farming tips grid with Article / Post / Video categories |
| Weather | Weather forecast by district with humidity, wind, sunrise/sunset details |
| Onboarding | 3-step welcome screens + farm profile setup |

*(Full screenshots included in the PDF report)*

---

## Flutter Analyze

```bash
flutter analyze
dart format lib/ test/
```

Output shows **0 issues**. Screenshot included in the PDF report.

---

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| flutter_bloc | ^8.1.3 | BLoC / Cubit state management |
| equatable | ^2.0.5 | Value equality for BLoC states/events |
| rxdart | ^0.27.7 | Reactive operators (debounce, switchMap) |
| dartz | ^0.10.1 | Functional `Either<Failure, T>` error handling |
| firebase_core | ^4.6.0 | Firebase initialization |
| firebase_auth | ^6.3.0 | Authentication |
| cloud_firestore | ^6.2.0 | NoSQL database |
| google_sign_in | ^7.2.0 | Google OAuth sign-in |
| shared_preferences | ^2.5.5 | Persistent local key-value storage |
| http | 1.6.0 | HTTP requests (WFP CSV, weather API) |
| google_fonts | ^8.0.2 | Typography (Source Sans 3) |
| cached_network_image | ^3.4.1 | Image caching with placeholder/error |
| youtube_player_flutter | ^9.0.2 | Embedded YouTube video player |
| url_launcher | ^6.3.2 | External link handling |
| intl | ^0.20.2 | Date/number formatting and localization |

---

**Group Contribution Tracker:** [Link to tracker](#)
