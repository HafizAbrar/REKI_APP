# Project optimization and validation

Updated 23 September 2026. The application launches through `lib/main.dart` and handles customer, business, admin, and worker roles in the same app.

## Completed improvements

- Shared in-flight metadata loads, a 128-entry LRU/TTL cache, and a four-request concurrency limit for legacy offer venue-city lookups. Fixed a completion callback that returned its own pending Future and could leave requests waiting indefinitely.
- One database-open Future shared across concurrent callers. Version-3 indexes support local history/review/check-in/saved-venue and sync queries; migration preserves existing records. Zero TTL reliably expires cache entries even within the same millisecond.
- One bounded token refresh for simultaneous 401 responses; request completion for missing/malformed/rejected refresh responses; transient server errors preserve credentials. Logout/account changes cannot be reversed by an older refresh result.
- Lazy discovery item construction, image decode-size limits, guarded silent refresh, owned/cancellable subscriptions and polling, and coalesced device registration.
- Reduced diagnostic body/token logging, modern Flutter APIs, and analyzer cleanup.
- Phase 6 contract corrections and centralized role navigation described in `PHASE6_IMPLEMENTATION.md`.

## Evidence

- `flutter analyze --no-pub`: **No issues found**.
- `flutter test --no-pub --reporter expanded`: **121 tests passed**.
- `git diff --check`: passed.
- Optimization regression fixture with eight legacy offers: first refresh makes nine HTTP requests; second refresh within TTL makes one additional request. Peak simultaneous venue-detail requests is at most four. These are deterministic test results, not production latency measurements.
- Concurrent auth tests verify a single refresh and completion of all waiting requests, including outage/failure paths.
- Database tests verify shared initialization and upgrade from version 2 without losing a stored preference.
- Role tests verify the four landing routes, worker restrictions, owner/admin access, customer/guest restrictions, and signed-out behavior.
- Contract tests cover string city coordinates, locale/city payloads, signed and legacy vouchers, announcements and expiry, city scoping, DST, and mutation retry restrictions.

Logs: `tool/optimization-analysis.txt`, `tool/optimization-tests.txt`, and `tool/phase6-app-build.txt`.

## Limits

These changes address specific correctness and resource-use problems. They do not establish device frame timings, production latency, memory benchmarks, full UI translation, authenticated production authorization, or the three-second QR target. Live production data was not mutated. The backend audit is in `PHASE6_BACKEND_REQUIREMENTS.md`.
`flutter build apk --debug --no-pub -t lib/main.dart` completed successfully and generated `build/app/outputs/flutter-apk/app-debug.apk`. Gradle returned zero; PowerShell classified Flutter's Android x86 support deprecation message on stderr as a NativeCommandError despite successful compilation. This is a debug build, not a release-performance benchmark.

24 September follow-up: RTL locale fallback fixed and tested; 126 tests passed and analysis is clean. Staging acceptance runner and remaining external inputs are documented in PHASE6_ACCEPTANCE.md.
