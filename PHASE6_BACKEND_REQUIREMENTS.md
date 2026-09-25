# Phase 6 live backend audit

Checked 25 September 2026 using https://api.reki.uk/api/docs-json and read-only HTTP requests. The previously absent Phase 6 routes remain documented.

## Conclusion

All 22 reviewed Phase 6 and supporting contracts are present in the live OpenAPI document. **No required route was found missing from that contract.** Public city and announcement reads succeeded. Protected reads returned 401 without credentials; mutation execution, role authorization, and redemption response shapes remain unverified. No live account, assignment, announcement, or redemption was created or changed.

| Required contract | Live OpenAPI |
|---|---|
| `GET /cities` | Present |
| `GET /cities/{slug}` | Present |
| `GET /cities/id/{id}` | Present |
| `GET /cities/detect` | Present |
| `PUT /users/city` | Present |
| `PUT /users/locale` | Present |
| `GET /users/location/city` | Present |
| `GET /worker/staff` | Present |
| `POST /worker/staff` | Present |
| `DELETE /worker/staff/{staffId}` | Present |
| `GET /worker/venues` | Present |
| `POST /worker/venues/{venueId}/assignments` | Present |
| `DELETE /worker/venues/{venueId}/assignments/{businessUserId}` | Present |
| `POST /worker/venues/{venueId}/status` | Present |
| `GET /worker/venues/{venueId}/live-info` | Present |
| `POST /worker/venues/{venueId}/live-info` | Present |
| `POST /worker/venues/{venueId}/redemptions/scan` | Present |
| `GET /venues/{id}/whats-on` | Present |
| `PUT /business/venues/{id}/whats-on` | Present |
| `GET /venues` | Present |
| `GET /offers` | Present |
| `GET /live/snapshot` | Present |

Other documented compatibility routes include `POST /offers/redeem-by-code`, `POST /users/location/city`, and `GET /cities/nearest`. The app uses the venue-specific worker scan route and `PUT /users/city`.

## Live read results

- `GET /cities`: 200; Manchester, London, and Birmingham are active.
- City slug lookup, detection around Manchester, and ID lookup using each real city UUID: 200.
- `GET /venues?city=manchester&limit=1`: 200, 17 venues; Manchester offers: 17.
- London and Birmingham venue and offer queries: 200, zero records. Configured cities do not establish that a second city has launched with feature parity.
- `GET /venues/{validVenueId}/whats-on`: 200, one current item for the audited venue.
- User city, business venues, worker venues, worker staff, worker live-info, and live snapshot reads: 401 unauthenticated.
- Authenticated guest runtime verification: `POST /auth/guest` returned 201, then `GET /live/snapshot?city=manchester` and `GET /venues?city=manchester&page=1&limit=20` returned 200 from the iOS app.
- A preliminary request using the slug `manchester` in the UUID endpoint `/cities/id/manchester` returned 500. Actual UUID lookups succeed. Backend input validation should return 400 for malformed IDs rather than 500; this is not a missing route.

## Confirmed request contracts and app corrections

| Feature | Required body / response | App correction |
|---|---|---|
| Preferred city | `PUT /users/city`: `{ "city": "manchester" }` | Send slug rather than `{cityId}` |
| Locale | `PUT /users/locale`: `{ "locale": "en-GB", "timezone": "Europe/London" }` | Send `locale` rather than `language`; parse locale tags |
| City responses | Decimal coordinate strings; `defaultLocale`; detection wraps city in `{city, distanceKm}` | Normalize strings and envelopes |
| QR scan | `{ "voucherCode": "REKI-..." }` or `{ "qrCodeData": "<signed token>" }` | Replace undocumented `code`; preserve signed QR payload |
| Live info | Required `type` (`music`, `offer`, `event`, `notice`) and `title`; optional `details`, `startsAt`, `endsAt`, `isActive` | Replace `message`/`expiresAt`; handle lists and visibility windows |
| Worker status | `{ "busyness": "quiet/moderate/busy" }` | Do not send owner-only vibe fields |
| Venue assignment | `{ "businessUserId": "<staff UUID>" }` | Add assignment/removal controls to staff management |

## Release checks still required

1. Authenticate an owner and assigned worker; verify creation, assignment/removal, cross-venue denial, and deactivated-worker denial.
2. Claim a real test voucher and scan it as assigned staff. Verify success, expiry, duplicate redemption, wrong venue, and network timeout behavior. The app currently requires a `transactionId` confirmation; live OpenAPI does not describe protected response bodies sufficiently to verify that field without an authenticated test.
3. Publish an announcement and confirm its public list response and expiry. No documented endpoint identifies an existing announcement for early edit/delete. The UI supports publishing and automatic expiry; its clear button clears the local draft only. If early retraction is needed, add a documented update/delete-by-ID contract (for example `PATCH`/`DELETE /worker/venues/{venueId}/live-info/{updateId}` with owner support).
4. Verify city isolation for protected live/sync feeds as well as discovery and offers.
5. Populate and launch a second city; verify the screenshot's 90% feature-parity target and under-three-second scanning on physical devices. Neither metric is established by this audit.

Machine-readable evidence: `tool/phase6-backend-audit.json`. Full live specification: `tool/phase6-live-openapi.json`. Repeat safely with `python tool/audit_phase6_backend.py`.
