# Phase 6 acceptance handoff

## Completed code work

Single app/four roles; locale-derived RTL and widget coverage; localized dates; live API payload alignment; non-sensitive QR timing trace. Final unit/widget suite: 126 passed. Analyzer: no issues.

## Staging configuration needed

Provide the staging HTTPS base URL and the local location of test credentials; do not put secrets into commits or chat. The acceptance runner reads these environment variables:

- `REKI_STAGING_URL`
- `REKI_STAGING_CUSTOMER_TOKEN`
- `REKI_STAGING_OWNER_TOKEN`
- `REKI_STAGING_WORKER_TOKEN`
- `REKI_STAGING_VENUE_ID` (owned by the test owner and assigned to the worker)
- `REKI_STAGING_OFFER_ID` (a currently claimable offer at that test venue; needed for mutation checks)

Run `python tool/phase6_staging_acceptance.py` for authenticated read/role checks. Run with `--mutate-test-records` to claim and redeem one designated test voucher, check duplicate rejection, and publish/read back a notice that expires after one minute. The runner refuses the known production origins and redirects, makes no retries, and writes only status/timing/pass results to `tool/phase6-staging-results.json`; it does not log account tokens, voucher contents, or response bodies. It has been syntax/CLI checked, but cannot be exercised against staging until configuration is supplied.

App staging launch remains the same application:

```sh
flutter run --dart-define=ENV=staging --dart-define=API_BASE_URL=https://YOUR-STAGING-HOST
```

The placeholder must be replaced with the real staging host. Setting ENV alone does not change the API base URL.

## Device acceptance

Use a physical phone and a profile build. Capture `reki.qr.decode_to_confirmation` in Dart DevTools. This measures processing after QR decoding through backend confirmation, including camera stop; it excludes initial camera acquisition and result rendering. Measure the complete visible scan-to-confirmation with screen recording/stopwatch as well. Record device, network, sample count, successes, median, p95, and all scans at or above three seconds. Do not infer the under-three-second target from HTTP timing or an emulator.

Test permission denial/manual entry, pause/resume, repeat frames, duplicate and expired vouchers, wrong venue, revoked assignment, account switching, and network timeout. Confirm an actual successful scan returns the transaction confirmation expected by the app before release.

## Second-city launch

Choose London or Birmingham and provide approved, real venue/offer records with addresses, coordinates, owner assignments, operating hours, validity windows, and permission to publish. No fabricated businesses have been inserted. Stage records first, then verify city-specific discovery, map, offers, saved venues, updates, and worker redemption. Record pass/fail for the same feature checklist in Manchester and the second city; demonstrate at least 90% parity before labeling that city launched.

Outstanding inputs are staging access, designated test fixtures, approved second-city content, and a connected physical device. Those are external requirements, not remaining RTL implementation bugs.
`flutter build apk --debug --no-pub -t lib/main.dart` succeeded after the RTL/timing changes; APK: `build/app/outputs/flutter-apk/app-debug.apk`.
