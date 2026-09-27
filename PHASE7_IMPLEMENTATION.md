# Phase 7 — Payments & Monetization & AI (client implementation)

Implemented in the Flutter client (backend contract in `PHASE7_BACKEND_REQUIREMENTS.md`).

## Payments & subscriptions (Stripe)
- `lib/features/subscription/data/subscription_models.dart` — Free/Pro/Enterprise tiers, static plan catalogue, `Subscription`, `UsageRecord` (usage-based billing).
- `lib/features/subscription/data/stripe_payment_service.dart` — Stripe Payment Sheet flow via `flutter_stripe`; configured with `--dart-define STRIPE_PUBLISHABLE_KEY=…`; backend supplies PaymentSheet params via `POST /payments/subscriptions/init-sheet`.
- `lib/core/network/payment_api_service.dart` — billing REST client (`/subscriptions/current`, `/billing/usage`, `/payments/portal-session`).
- `lib/features/subscription/presentation/paywall_screen.dart` — plan picker + payment (`/paywall`).
- `lib/features/subscription/presentation/billing_screen.dart` — plan status, renewal, monthly usage breakdown, Stripe customer portal (`/billing`).
- `lib/features/subscription/presentation/widgets/feature_gate.dart` — wraps premium screens; Free users see an upgrade prompt.
- `subscription_providers.dart` — `currentSubscriptionProvider`, `currentTierProvider`, `currentUsageProvider`.

## Smart recommendations
- `lib/features/recommendations/data/recommendation_engine.dart` — deterministic scoring: user type/vibe affinities (interaction memory = client-side collaborative signals reconcilable with backend scores) × time-of-day type weights × weather-aware boosts × live-offer boost.
- `lib/features/recommendations/data/weather_service.dart` — free Open-Meteo API (no key), fails soft to neutral.
- `lib/features/recommendations/presentation/recommendation_providers.dart` — persisted affinities (`SharedPreferences`), `recommendationsProvider` (top-N for the selected city).
- `recommended_section.dart` — "Recommended for you" carousel for the home screen.

## Predictive AI
- `lib/features/predictions/data/crowd_prediction_service.dart` — weekday × hour historical-mean model with confidence; backend history via `GET /venues/{id}/busyness/history` with a local rolling-history fallback (`CrowdHistoryStore`).
- `lib/features/predictions/data/smart_notification_timing.dart` — sends venue heads-ups ~2h before predicted peaks, respecting the user's quiet-hours preference. Pure functions, unit-tested.
- `lib/features/predictions/presentation/prediction_badge.dart` — "Expect busy ~19:00" badge (hidden below 30% confidence).

## Route additions
`/paywall`, `/billing` (business), `/onboarding` (Phase 8).

## Verification
`flutter test test/phase7_test.dart` covers the engine, prediction model, timing, and models (11 assertions).

## Configuration (production)
```
flutter run --dart-define=STRIPE_PUBLISHABLE_KEY=pk_live_… \
            --dart-define=STRIPE_PRICE_PRO=price_… \
            --dart-define=STRIPE_PRICE_ENTERPRISE=price_…
```
