# Phase 6 implementation

## One application, four roles

Run the existing application normally:

```sh
flutter run
# equivalent: flutter run -t lib/main.dart
```

Customer, business, admin, and worker use the same installed app and launch target. Separate customer/worker entry points and module flags have been removed at the user's request. `role_navigation.dart` provides the shared login/restored-session landing policy and route guards:

| API role | Landing screen |
|---|---|
| USER / guest | `/home` |
| BUSINESS | `/business-dashboard` |
| ADMIN | `/admin-dashboard` |
| WORKER | `/worker-home` |

Existing customer, business, and admin screens remain. Workers get assigned venues, QR scanning/manual entry, busyness updates, and What's On publishing. They cannot access owner staff management, offer management, or admin screens. Backend authorization must enforce assignment and role permissions independently of UI guards.

## Phase 6 implementation

- City selection with local metadata snapshots, offline fallbacks, explicit GPS detection, and startup detection only when permission is already granted. Live string coordinates, default locale, and detection envelopes are supported.
- City-scoped discovery, maps, offers, and supported live/sync requests; provider refresh and stale-response safeguards when switching cities; saved-venue filtering and city notification topics.
- Staff creation/deactivation and owner venue assignment/removal controls. Worker status loads assigned venues rather than an owner-only status endpoint.
- Camera scanning and manual code entry, signed QR and legacy voucher support, venue context, duplicate-frame suppression, paused camera while processing/backgrounded, and no automatic mutation retries after network/server errors.
- Live announcements use documented type/title/endsAt fields. Customer display handles lists, optional expiry, future start times, and inactive entries. Publishing is supported; clearing is local draft clearing, not server deletion.
- Flutter localization delegates, RTL foundation, locale tag parsing, and timezone/DST-aware dates. Product strings are still largely English; this is not a claim of complete translated UI coverage.

See [PHASE6_BACKEND_REQUIREMENTS.md](PHASE6_BACKEND_REQUIREMENTS.md) for current deployed contracts, successful public reads, and authenticated acceptance checks. The earlier missing-endpoint report is superseded.

## Optimization

- Bounded metadata cache with request coalescing and expiry; offer metadata requests capped at four concurrent calls.
- Shared database opening and version-3 indexes for local history, reviews, check-ins, saved venues, and sync queue; deterministic zero-TTL expiry.
- Single-flight token refresh with bounded waits; transient refresh/replay failures preserve credentials; stale refreshes cannot restore a logged-out session.
- Lazy discovery list construction, bounded image decode sizes, cancellable subscriptions/polling, coalesced device registration, and restricted diagnostic logging.
- Updated deprecated APIs and analyzer findings throughout the existing project. These are targeted improvements, not a measured claim that every screen or algorithm is optimal.

## Validation and limits

Final validation results are recorded in `PROJECT_OPTIMIZATION.md` and `tool/optimization-*.txt`.

No production data was modified. Physical-device camera timing, authenticated worker/owner end-to-end operations, iOS build/signing, and multi-city business launch remain acceptance checks. Android debug compilation does not establish release performance.
Final verification: 121 tests passed, static analysis found no issues, and the single-app Android debug APK was built at `build/app/outputs/flutter-apk/app-debug.apk`.

24 September follow-up: RTL locale fallback fixed and tested; 126 tests passed and analysis is clean. Staging acceptance runner and remaining external inputs are documented in PHASE6_ACCEPTANCE.md.
