# Racha — mobile (`apps/mobile`)

Flutter 3.x / Dart 3 client. Riverpod for state, go_router for navigation, dio
for HTTP (with a single-flight 401-refresh interceptor), flutter_secure_storage
for the token pair.

- **i18n from day one:** no literal strings in widgets. Keys live in
  `lib/l10n/app_es.arb` (runtime default) and `lib/l10n/app_en.arb` (key
  reference). Regenerate with `flutter gen-l10n`.
- **Design tokens:** `lib/theme/tokens.dart` — one seed (`#8E2C4E`),
  `ColorScheme.fromSeed` for light **and** dark. Seven spaces, four radii, three
  shadows, seven text sizes. Hierarchy by tone + 1px border, not shadow.
- **Structure:** `lib/features/<feature>/{data,domain,application,presentation}`.

## Run

```sh
flutter pub get
# The default API_BASE_URL is https://api.racha.app (production), so local dev
# MUST pass an explicit --dart-define:
# iOS simulator can reach the host directly:
flutter run --dart-define=API_BASE_URL=http://localhost:8080
# Android emulator uses the host loopback alias:
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

Cleartext (`http://`) is only permitted in **debug** builds, and only to
loopback hosts — see `android/app/src/debug/res/xml/network_security_config.xml`.
A release build pointed at an `http://` URL throws at startup by design.

## Release build (Android)

```sh
# One-time: create the upload keystore and android/key.properties
cp android/key.properties.example android/key.properties   # then edit it
# Build the store bundle (signed with the real keystore, R8 + resource shrink on):
flutter build appbundle --release --dart-define=API_BASE_URL=https://api.racha.app
```

`android/key.properties` and `*.jks` are git-ignored. Enrol the app in Play App
Signing so Google holds the app signing key.

## Analyze & test

```sh
flutter analyze
flutter test
```

## Status — MVP vertical slices

| Slice | State |
|-------|-------|
| Foundation: theme (light/dark), go_router with every design route, dio client + refresh interceptor, secure token storage, session controller, ARB setup | **done** |
| Auth: Splash bootstrap (`GET /me` routing), Onboarding, Login, Register with live validation + inline errors | **done** |
| Pairing: `/couple/setup` fork, `/couple/create` (name + IANA zone), `/couple/join` (6-char uppercase, paste), `/couple/waiting` (big code, copy/share, soft polling → auto-advance) | **done** |
| Home (`/home`): animated streak counter — respects "reduce motion" — 12-week strip, week-status colour (amber only when at risk), recent dates, FAB, empty state | **done** |
| Register a date: `/dates/new` (debounced place search via backend, "no place") → `/dates/new/details` (title, no-future date picker, stars, notes, cost, tag chips + "won't count" warning, `Idempotency-Key`, streak-advance snackbar) | **done** |
| Timeline (`/dates`): cursor-paginated infinite scroll, tappable cards with place / relative date / rating / "doesn't count" tag | **done** |
| Date detail (`/dates/:id`): view with a small flutter_map/OSM map, edit (`/dates/:id/edit`), delete with a streak-drop warning | **done** |
| Summary (`/summary`): totals, favourite, category bars, ranked place list; Map (`/places/map`): flutter_map + OSM tiles, pins sized by visits, tap sheet, OSM attribution | **done** |
| Profile (`/profile`): couple numbers, dates-per-month bars, server-side sign-out | **done** (basic) |
| Account recovery: `/auth/forgot-password`, `/auth/reset-password` (token from the email link or pasted), `/auth/verify-email` (auto-verify from link, resend with cooldown), `/account` — verify status, delete-account with typed-email confirmation, cancel-deletion tile | **done** |
| Notifications (`/profile/notifications`): a switch per type with a real text example, reminder-hour dropdown, quiet-hours picker | **done** |
| Home banners: unverified email, pending-deletion (strong) | **done** |
| Push device registration | needs a Firebase project (`firebase_messaging` not wired) |
| Account recovery / deletion, notifications screen | pending |

Screens not yet built resolve to `PlaceholderScreen` so navigation already works.
