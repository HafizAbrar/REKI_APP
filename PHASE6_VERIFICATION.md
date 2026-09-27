# Phase 6 verification — updated 25 September 2026

## Verdict

Phase 6 is implemented substantially on the app side, but **not fully verified working or complete against all acceptance criteria**. The user's single-app requirement supersedes the screenshot's separate-app suggestion. Customer, business, admin, and worker share `lib/main.dart`.

## Requirement assessment

| Requirement | Evidence | Status |
|---|---|---|
| Dedicated worker interface in the same app | Role landing policy, guarded staff screens, assigned venues, staff management and assignment controls | Implemented; role-policy tests pass |
| Camera QR redemption | Camera/manual entry, signed/legacy payloads, venue-specific scan API, duplicate protection, no mutation retries | Implemented; live authenticated redemption and physical camera not verified |
| What's On and busyness | Documented publishing/status payloads, customer announcement lists, expiry checks | Implemented; authenticated publish/readback not verified; customer updates poll every 15 seconds rather than instant push |
| City selection and detection | Saved selection, GPS detection, live city API, decimal coordinate parsing | Implemented; public city endpoints verified |
| Active-city filtering | Scoped discovery/offer/live/sync requests and legacy offer filtering | App/test coverage present; protected feed isolation still needs authenticated verification |
| RTL foundation | Localization delegates and explicit RTL metadata supported | Fixed: locale-derived RTL, explicit direction overrides, and city-switch widget regression coverage |
| Localized date/time | City timezone conversion, intl formatting, DST tests | Implemented foundation; no full translated-UI/device layout verification |
| 2+ cities launched with 90% feature parity | Three active city records, but London and Birmingham have zero venues/offers | Not demonstrated |
| QR scan under 3 seconds | No physical-device end-to-end timing | Not verified |

## Code gap closed

The locale-derived RTL bug is fixed. `City.fromJson` derives direction from the preferred locale when explicit direction metadata is absent. The shared production `CityLocalization` widget preserves Persian/Hebrew/Urdu and locale script/region subtags. Regression tests cover Arabic defaults, explicit overrides, persisted metadata, and switching RTL/LTR cities.

Latest validation: **139 tests passed**, **static analysis clean**. Scan tracing is available as `reki.qr.decode_to_confirmation` in Dart DevTools timelines; it contains no voucher/token data and is not proof of the full camera-to-confirmation target.

## iOS production integration check

The app was run on an iPhone 17 simulator against `https://api.reki.uk`. Guest authentication returned 201, and the Manchester live snapshot and full venue requests returned 200. Google map tiles, simulated Manchester location, RAG-coloured venue markers, category filtering, hybrid map style, marker selection, venue details, and the live home feed were exercised successfully.

This check exposed and closed a production-only map defect: `/live/snapshot` returns lightweight venue status records without coordinates. Those records were previously accepted as complete venues, placing markers at `(0, 0)`. The provider now detects incomplete map data and falls back to `GET /venues`, which restored all Manchester venue markers. Regression tests reject missing and geographically invalid coordinates.

Push delivery is not verified in the simulator because it does not receive a real APNs token. The signed Ad Hoc build must be installed on the registered physical device for that check.

## Backend evidence

Fresh audit timestamp and individual results are in `tool/phase6-backend-audit.json`. All 22 reviewed required/supporting contracts are documented. No required route was found missing from live OpenAPI.

- City list, slug/UUID lookup, location detection, and public What's On GET: HTTP 200.
- Manchester: 17 venues and 17 offers; one public What's On item was returned for the audited venue.
- London and Birmingham: zero venues and zero offers each.
- Protected worker/staff/live-info/user-city/live-snapshot reads: HTTP 401 without credentials.
- No production mutations were performed. A documented route and an unauthenticated 401 do not prove role authorization or successful writes.
- The app requires `transactionId` to confirm redemption. The protected response schema is not specified sufficiently in OpenAPI; verify the real successful response before declaring scanning operational.

## Remaining acceptance work

1. Completed: locale-derived RTL fallback and actual production direction-widget tests.
2. Use authorized test owner/worker/customer accounts to verify staff assignment, wrong-venue denial, revoked access, real claim-to-scan redemption, duplicate/expired vouchers, and publish-to-customer visibility.
3. Confirm protected feed city isolation and offline/switch-city behavior on a device.
4. Run physical camera permission/background/resume tests and measure complete scan-to-confirmation latency.
5. Populate and launch a second city, then measure feature parity. Active configuration alone is not launch evidence.

The full automated suite and static analysis were rerun after the map correction. The iOS simulator build also succeeded and was exercised against production. No claim of authenticated role/mutation or physical-device end-to-end success is made.

## Staging handoff

The user selected staging test accounts. No staging URL or account configuration has been supplied. The only local API origin is production (`https://api.reki.uk`), and no staging environment variables are configured. No physical device is currently attached as of the 25 September check. Therefore authenticated staging tests, physical-device timing, push delivery, and second-city launch cannot honestly be marked complete.

See `PHASE6_ACCEPTANCE.md` for the executable staging check and exact remaining inputs.
