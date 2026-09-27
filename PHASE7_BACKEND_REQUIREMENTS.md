# Phase 7 Backend Contract

Base URL: `https://api.reki.uk`. Business and personalized routes require a
bearer JWT. Stripe secret keys remain on the backend.

## Payments And Subscriptions

| Route | Purpose |
|---|---|
| `GET /subscription-plans` | Active public plan catalogue. |
| `GET /subscriptions/current` | Current business subscription and plan. |
| `POST /payments/subscriptions/init-sheet` | Accepts `{ plan, billingPeriod, idempotencyKey }`, where plan is `PRO` or `ENTERPRISE` and billing period is `MONTHLY` or `YEARLY`. Returns Stripe Payment Sheet parameters. |
| `GET /billing/usage?period=YYYY-MM` | Usage-based billing breakdown. |
| `POST /payments/portal-session` | Creates a Stripe Customer Portal session. |
| `POST /payments/webhooks/stripe` | Verifies Stripe signatures and synchronizes subscription and entitlement state. |

The backend must enforce plan limits authoritatively, meter billable usage,
configure active Stripe prices, and make Pro and Enterprise visible through
`/subscription-plans`.

## Recommendations And Prediction

| Route | Purpose |
|---|---|
| `GET /recommendations?latitude=...&longitude=...&limit=...` | Collaborative recommendation ranking. The client blends these scores with time, weather, busyness, and local affinity signals. |
| `POST /recommendations/events` | Records interaction feedback such as `recommendation_click`. |
| `GET /venues/{id}/busyness/history?from=...&to=...` | Historical observations used by the local fallback model. |
| `GET /venues/{id}/busyness/predictions?from=...&hours=...` | Server-generated crowd forecasts. |

## Production Acceptance

- Validate a complete Stripe test-mode purchase, webhook update, portal visit,
  cancellation, and reactivation flow before enabling live mode.
- Monitor attempted and successful payments to verify the 98% target.
- Track paid conversions against eligible businesses for the three-month goal.
- Monitor recommendation event volume, forecast confidence, and model drift.
