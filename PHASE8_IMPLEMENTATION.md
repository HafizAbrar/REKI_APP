# Phase 8 — Platform Maturity & Scale (client implementation)

## Security hardening
- **Certificate pinning** — `lib/core/security/certificate_pinning.dart` pins the SHA-256 of the server certificate via a custom Dio `IOHttpClientAdapter`. Configure with `--dart-define CERT_PINS="pin1,pin2"` (current + next-rotation pin). Wired into `lib/core/network/api_client.dart`. Backend/dev must publish both pins before rotation.
- **Jailbreak/root & tamper detection** — `lib/core/security/app_security_service.dart` using freeRASP. Fail-open in debug; production wiring expects `ANDROID_SIGNING_CERT_HASH` and `APPLE_TEAM_ID` dart-defines. Hard threats call the `onHardThreat` hook (zero-trust exit/blocking screen).
- **Rate limiting** — `lib/core/network/interceptors/rate_limit_interceptor.dart`: honours `Retry-After` on HTTP 429, capped exponential backoff, max 2 retries. Server-side abusive traffic must additionally be limited by the API gateway/WAF (out of repo scope).
- **Biometric auth** — `lib/core/security/biometric_auth_service.dart` (`local_auth`): FaceID/TouchID/fingerprint with device-PIN fallback, for sensitive actions (business dashboard entry, payout changes).

## Accessibility (WCAG AA)
- New screens/widgets ship `Semantics` labels (`paywall_screen`, `onboarding_screen`, `recommended_section`, `prediction_badge`, `feature_gate`) with `ExcludeSemantics` on decorative icons — VoiceOver/TalkBack friendly.
- Dynamic font scaling: all text styles come from `Theme.of(context).textTheme` — honour the OS font scale (no hard-coded `textScaler` overrides). Verify on-device at 200% scale.
- Contrast: `AppTheme.darkTheme` (slate-900 background, teal-300 primary) — primary on background ≈ 11:1; body text white70 on surface ≈ 8:1. Both exceed WCAG AA (4.5:1 normal, 3:1 large). Error red (#EF4444) on slate-900 ≈ 4.6:1 — AA for body sizes ≥12sp used by input errors.

## ASO & DevOps
- **Onboarding** — `lib/features/onboarding/presentation/onboarding_screen.dart` (`/onboarding`), shown once on first run (splash routes there before login; flag in SharedPreferences).
- **Rating prompts** — `lib/core/services/app_rating_service.dart` (`in_app_review`); prompts after 3 positive moments, 90-day cooldown, 3× lifetime cap; `openStoreListing()` for settings menus.
- **CI/CD** — `.github/workflows/flutter_ci.yml`: analyze + test on every push/PR; release AAB on main; Fastlane `android/fastlane/Fastfile` deploys to Google Play internal track on version tags (`v*`). Secrets: `ANDROID_KEYSTORE_BASE64`, `CERT_PINS`, `STRIPE_PUBLISHABLE_KEY`, `PLAY_STORE_CONFIG_JSON`.

## Observability
- `lib/core/services/observability_service.dart` — Crashlytics custom keys (`role`, `city`, user id), non-fatal reporting, custom product events, and **automated backend-failure alerting**: >10 backend failures/5 min from a client burst → `POST /observability/alerts`. Backend should wire this to PagerDuty/Slack; APM (Datadog/Sentry) is a backend-side addition.

## Uptime (99.9%+)
Achieved server-side; client contributes resilience: retry interceptor, offline sync, rate-limit backoff, fail-open on non-critical subsystems (weather, RASP, analytics).

## Verification checklist
- [ ] `flutter analyze --fatal-warnings` clean.
- [ ] `flutter test` green (incl. `test/phase7_test.dart`).
- [ ] TalkBack pass on onboarding/paywall/home at 200% font scale.
- [ ] CI green on `main`; tag `v1.0.0` → internal-track deploy.
