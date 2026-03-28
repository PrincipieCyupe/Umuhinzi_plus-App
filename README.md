# Umuhinzi Plus — Agricultural Mobile Application

A Flutter mobile application that empowers Rwandan farmers with real-time market prices, farming tips, weather forecasts, and personalized crop guidance. Built with Clean Architecture, BLoC state management, and Firebase backend.

---

## GitHub Repository

**Repository:** [https://github.com/PrincipieCyupe/Umuhinzi_plus-App](https://github.com/PrincipieCyupe/Umuhinzi_plus-App)


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

**Umuhinzi Plus** (Umuhinzi = "Farmer" in Kinyarwanda) is a mobile-first app designed for Rwandan smallholder farmers. It aggregates:

- Live market produce prices from Firestore (user-contributed) and WFP Rwanda food price data
- Weather forecasts by district using OpenWeatherMap
- Curated farming tips and YouTube video tutorials
- Personalized onboarding based on crop, season, province, and district

Target platforms: **Android** (primary), Web (secondary).

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
git clone https://github.com/YOUR_USERNAME/umuhinzi_plus.git
cd umuhinzi_plus
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Firebase Configuration

The `lib/firebase_options.dart` file is already included in the repository and pre-configured for the `umuhinzi-plus` Firebase project. No additional Firebase setup is required to run the app.

If you need to connect to your own Firebase project:

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure your project
flutterfire configure
```

Then enable in your Firebase console:
- **Authentication:** Email/Password provider and Google Sign-In provider
- **Cloud Firestore:** Create database in production mode
- **Security Rules:** Apply the rules described in the [Firebase Security Rules](#firebase-security-rules) section

### 4. Run the App

```bash
# Run on a connected Android device or emulator
flutter run

# Run with a specific device
flutter run -d <device_id>

# List available devices
flutter devices
```

### 5. Build a Release APK

```bash
flutter build apk --release
```

The APK is output to `build/app/outputs/flutter-apk/app-release.apk`.

### 6. Run Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Generate coverage report (requires lcov)
genhtml coverage/lcov.info -o coverage/html
```

### 7. Generate Mock Files (if needed)

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
│   └── utils/           # Page transition animations
└── features/
    ├── home/            # Auth screens, onboarding, weather BLoC, navigation
    │   ├── data/        # WeatherRepository, LocalStorageService, WeatherService
    │   ├── domain/      # WeatherEntity
    │   ├── presentation/# WeatherBloc, InputDetailsBloc, NavigationCubit
    │   ├── screens/     # Login, Signup, ForgotPassword, Welcome, HomeScreen
    │   └── service/     # AuthService (Firebase Auth wrapper)
    ├── market/          # Market produce prices
    │   ├── data/        # MarketRemoteDataSource, MarketCsvDataSource,
    │   │                #   MarketPriceFirestoreSource, PreferencesService
    │   ├── domain/      # ProduceEntity, use cases (AddProduce, DeleteProduce,
    │   │                #   UpdateProduce, GetProduceByCategory, SearchProduce)
    │   └── presentation/# MarketBloc, MarketPriceCubit, widgets, MarketPage
    ├── tips/            # Farming tips and YouTube videos
    │   ├── data/        # TipsLocalDataSource, YoutubeDataSource
    │   ├── domain/      # TipEntity, GetTips use case
    │   └── presentation/# TipsBloc, TipsPage, ArticleReaderPage, VideoPlayerPage
    └── weather/         # WeatherPage UI
```

### Layer Responsibilities

| Layer | Responsibility |
|-------|---------------|
| **Presentation** | UI widgets, BLoC/Cubit event dispatch, state rendering |
| **Domain** | Business entities, use-case classes, repository interfaces |
| **Data** | Repository implementations, remote/local data sources, model serialization |

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

- `market_prices.district` logically references the user's `selected_district` in SharedPreferences to filter relevant price data
- `market_produce` documents are user-visible items managed through the app UI (full CRUD)
- `market_prices` documents are ingested automatically from the WFP Rwanda food prices CSV dataset via a background sync service

### Indexes

| Collection | Field | Order | Purpose |
|-----------|-------|-------|---------|
| `market_produce` | `category` | — | Filter by category |
| `market_produce` | `name` | Ascending | Prefix search |
| `market_prices` | `district` | — | Location filter |
| `market_prices` | `date` | Descending | Latest prices first |

---

## Implemented Functionalities

### Onboarding
- Welcome screens (3-step introduction)
- Farm profile setup: crop selection, season, province, and district
- Profile data persisted to SharedPreferences; pre-fills on return

### Authentication
- Email/password registration with input validation
- Email/password login
- Google Sign-In (OAuth, mobile and web)
- Password reset via email link
- Logout (clears Firebase and Google sessions)
- 14 Firebase Auth error codes mapped to user-friendly messages
- Auth state persisted across app restarts via `FirebaseAuth.authStateChanges()` stream

### Market — Full CRUD
| Operation | Trigger | Firestore action |
|-----------|---------|-----------------|
| **Create** | "Add Produce" form | `collection.add(doc)` |
| **Read** | App launch / category tab | `collection.where().snapshots()` stream |
| **Update** | Edit dialog on produce card | `doc.update(fields)` |
| **Delete** | Swipe or delete button | `doc.delete()` |

- Real-time category filtering with `MarketBloc`
- Debounced prefix search (300ms via RxDart `debounceTime`)
- Last selected category and currency saved to SharedPreferences

### Market Prices (WFP Data)
- Background sync of WFP Rwanda food price CSV on app startup
- 30-minute periodic refresh via `MarketPriceCubit` timer
- Batch write to Firestore with deduplication by compound key
- District-filtered price display based on user's selected district

### Weather
- Current weather by district using OpenWeatherMap API
- Fetch by district name or GPS coordinates
- WeatherBloc manages loading/error/data states
- Weather shortcut from home tab via NavigationCubit

### Farming Tips
- Categorized farming tips with full article reader
- Embedded YouTube video tutorials via `youtube_player_flutter`
- Search and category filter managed by TipsBloc

### Navigation
- Bottom navigation bar (Home, Weather, Market, Tips) managed by NavigationCubit
- Custom page transitions: `FadeRoute` and `SlideUpRoute`
- Drawer with profile update and quick navigation shortcuts
- Auth-gated routing via `StreamBuilder<User?>` on `authStateChanges()`

---

## Authentication

### Method 1: Email / Password

```
Register → validate email regex + 6-char password → Firebase createUserWithEmailAndPassword()
Login    → validate → Firebase signInWithEmailAndPassword()
Reset    → Firebase sendPasswordResetEmail()
```

Validation rules:
- Email: regex `^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$`
- Password: minimum 6 characters

### Method 2: Google Sign-In

```
Mobile: GoogleSignIn.instance.authenticate() → OAuthCredential → Firebase signInWithCredential()
Web:    GoogleAuthProvider → Firebase signInWithPopup()
```

Sign-out clears both Firebase and Google sessions.

---

## State Management

All features use **BLoC / Cubit** from `flutter_bloc ^8.1.3`. The app avoids business logic inside widgets.

| BLoC / Cubit | Feature | Pattern |
|-------------|---------|---------|
| `MarketBloc` | Market produce | `emit.forEach()` on repository streams |
| `MarketPriceCubit` | WFP prices | Periodic sync + stream filtering |
| `WeatherBloc` | Weather data | Repository + use-case injection |
| `InputDetailsBloc` | Farm profile | Form validation + SharedPrefs persistence |
| `TipsBloc` | Tips / videos | In-memory filter + category state |
| `NavigationCubit` | Bottom nav | Tab index state |

The `Either<Failure, T>` type from `dartz` is used across all repository interfaces, keeping error propagation explicit and testable.

---

## Firebase Security Rules

The following Firestore security rules are applied to protect user data:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Market produce: any authenticated user can read;
    // only authenticated users can write their own entries
    match /market_produce/{produceId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null;
    }

    // Market prices: read-only for authenticated users;
    // writes are restricted to server-side sync operations
    match /market_prices/{priceId} {
      allow read: if request.auth != null;
      allow write: if false; // populated via batch writes only
    }

    // Tips: read-only for authenticated users;
    // content is managed by admins from the Firebase console
    match /tips/{tipId} {
      allow read: if request.auth != null;
      allow write: if false; // admin-managed only
    }
  }
}
```

**How these rules protect data:**
- All Firestore access requires an authenticated Firebase user (`request.auth != null`), preventing anonymous reads or writes
- `market_prices` is write-protected at the rule level — data is only populated by the WFP sync batch, not by end users
- Future improvement: restrict `market_produce` updates/deletes to the document's original creator by storing a `createdBy: uid` field and adding `request.auth.uid == resource.data.createdBy`

---

## SharedPreferences / User Preferences

The app stores and restores the following preferences across sessions:

| Key | Type | Feature | Restored on |
|-----|------|---------|-------------|
| `user_name` | String | Profile | App launch |
| `user_email` | String | Profile | App launch |
| `selected_crop` | String | Onboarding | Home screen |
| `selected_season` | String | Onboarding | Home screen |
| `selected_province` | String | Onboarding | Input screen |
| `selected_district` | String | Onboarding | Weather + Market filter |
| `is_onboarding_complete` | Bool | Routing | Auth wrapper |
| `language` | String | Localization | App theme |
| `last_selected_category` | String | Market | Market page |
| `preferred_currency` | String | Market | Market page |
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
| `market_price_filter_test.dart` | Unit | Price filtering logic |
| `produce_card_test.dart` | Widget | ProduceCard widget rendering |
| `widget_test.dart` | Widget | General app widget smoke test |

### Running Tests

```bash
# All tests
flutter test

# With coverage
flutter test --coverage
```

> **Screenshots of test results and coverage report are included in the PDF report.**

---

## Known Limitations and Future Work

### Known Limitations

1. **iOS not configured** — `firebase_options.dart` only targets Android and Web. Running on an iOS device requires adding an iOS Firebase app in the Firebase console and re-running `flutterfire configure`.
2. **Tips are read-only** — Farming tips are curated and hardcoded locally; there is no admin interface to add or remove tips from within the app.
3. **WFP data sync requires internet on first launch** — The app fetches WFP CSV data over the network. If the first launch is offline, market prices will be empty until connectivity is restored.
4. **No email verification** — Users can register and access the app without verifying their email address.
5. **Weather API key is public** — The OpenWeatherMap API key is bundled in the app binary. For production, this should be moved to a Cloud Function or remote config.
6. **Market produce images** — Image URLs are user-supplied strings with no validation. A malformed URL shows a fallback icon via `CachedNetworkImage`'s `errorWidget`.

### Future Work

1. **Email verification** — Implement `user.sendEmailVerification()` immediately after registration and block app access until verified.
2. **Admin role and tips CRUD** — Add an admin flag to Firebase Auth custom claims to allow tip creation, editing, and deletion from within the app.
3. **iOS support** — Configure Firebase for iOS and test on physical iPhone devices.
4. **Push notifications** — Use Firebase Cloud Messaging to alert farmers when market prices change significantly or when weather alerts are issued for their district.
5. **Offline mode** — Enable Firestore offline persistence (`FirebaseFirestore.instance.settings`) so that previously fetched produce prices remain accessible without internet.
6. **Localization** — Fully implement Kinyarwanda (`rw`) and French (`fr`) translations using Flutter's `intl` package and ARB files; the language preference key is already stored.
7. **Producer profiles** — Store `market_produce` documents with a `createdBy` field to support per-user history, reputation, and ownership-restricted edit/delete rules.
8. **Crop disease detection** — Integrate a TensorFlow Lite model for on-device plant disease identification from camera photos.

---

## Screenshots

> Screenshots are included in the PDF report. Place representative app screenshots below:

| Screen | Description |
|--------|-------------|
| ![Login](docs/screenshots/login.png) | Login screen with email/password and Google Sign-In |
| ![Home](docs/screenshots/home.png) | Home tab with quick actions and weather summary |
| ![Market](docs/screenshots/market.png) | Market produce list with category tabs and search |
| ![Market Prices](docs/screenshots/market_prices.png) | WFP district market prices |
| ![Tips](docs/screenshots/tips.png) | Farming tips with article reader |
| ![Weather](docs/screenshots/weather.png) | Weather forecast by district |
| ![Onboarding](docs/screenshots/onboarding.png) | Farm profile setup screens |

---

## Flutter Analyze

Run the following before submission to confirm zero warnings:

```bash
flutter analyze
dart format lib/ test/
```

> A screenshot of `flutter analyze` output (0 issues) is included in the PDF report.

---

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_bloc` | ^8.1.3 | BLoC / Cubit state management |
| `equatable` | ^2.0.5 | Value equality for BLoC states/events |
| `rxdart` | ^0.27.7 | Reactive operators (debounce, switchMap) |
| `dartz` | ^0.10.1 | Functional `Either<Failure, T>` error handling |
| `firebase_core` | ^4.6.0 | Firebase initialization |
| `firebase_auth` | ^6.3.0 | Authentication |
| `cloud_firestore` | ^6.2.0 | NoSQL database |
| `google_sign_in` | ^7.2.0 | Google OAuth sign-in |
| `shared_preferences` | ^2.5.5 | Persistent local key-value storage |
| `http` | 1.6.0 | HTTP requests (WFP CSV, weather API) |
| `google_fonts` | ^8.0.2 | Typography (Source Sans 3) |
| `cached_network_image` | ^3.4.1 | Image caching with placeholder/error |
| `youtube_player_flutter` | ^9.0.2 | Embedded YouTube video player |
| `url_launcher` | ^6.3.2 | External link handling |
| `intl` | ^0.20.2 | Date/number formatting and localization |

---

## Team

> List all group members and their primary contributions here.

| Member | Contributions |
|--------|--------------|
| Member 1 | |
| Member 2 | |
| Member 3 | |
| Member 4| |
| Member 5 | |

> Link to group contribution tracker: [Group Contribution Tracker](https://docs.google.com/spreadsheets/d/1S5nvhJq2Y88JTmb-V5f4Jz3ZfLXnoLQGjUfQ5A0XUQs/edit?usp=sharing)
