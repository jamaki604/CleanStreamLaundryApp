# Cortina QR rollout setup

The code is implemented but intentionally does not enable or deploy production vending. Complete these items in order.

## Current sandbox state

- The Cortina database migrations are applied to Clean Stream Supabase project `dnuuhupoxjtwqzaqylvb`.
- `cortina-vend`, `nayax-sale-end-sandbox`, `nayax-sale-end`, and the Cortina-aware `stripeWebhook` are deployed.
- The web preview is configured as the temporary payment origin and return URL.
- Live quote and callback smoke tests pass. Existing machine mappings remain disabled and require review.
- The database currently contains one 12 kg washer at its preserved $2.00 price. There is no dryer machine row yet.
- The Nayax one-time secret link in the integration email has expired. A replacement token and the exact payment-method name used in the Start URL are required before a hardware vend.

## 1. Nayax

Obtain and set separate sandbox and production values:

- Cortina StaticQR Start endpoint URL
- Secret token
- Payment-method name, if Nayax requires it during account provisioning
- `TerminalId` or full `UniQR` for each device
- `PulseLineNumber` for each connected washer and dryer

Ask Nayax to register these callback bases and append the documented routes:

- Sandbox: `https://dnuuhupoxjtwqzaqylvb.supabase.co/functions/v1/nayax-sale-end-sandbox`
- Production: `https://dnuuhupoxjtwqzaqylvb.supabase.co/functions/v1/nayax-sale-end`
- Routes: `/Cortina/StaticQR/Sale`, `/Cortina/StaticQR/Void`, `/Cortina/SaleEndNotification`

Confirm that a single Start request containing the selected dryer amount produces five minutes per $0.25. Also confirm callback authentication and whether Nayax requires fixed IP allowlisting, VPN, or mTLS.

Nayax's June 29 email says the dryer supports up to six configured multi-price options. The customer UI currently offers 18 amounts from $0.25 through $4.50, so do not enable a dryer until Nayax confirms whether one Pulse Line Start with an arbitrary `Price` creates the corresponding number of five-minute credits. If it does not, limit the UI to the configured product options returned by Clean Stream.

## 2. Supabase secrets

Set these secrets in project `dnuuhupoxjtwqzaqylvb`:

```text
NAYAX_SANDBOX_START_URL
NAYAX_PRODUCTION_START_URL
NAYAX_SANDBOX_SECRET_TOKEN
NAYAX_PRODUCTION_SECRET_TOKEN
CLEAN_STREAM_PAY_URL=https://cleanstreamlaundry.com/pay
CLEAN_STREAM_WEB_ORIGIN=https://cleanstreamlaundry.com
CORTINA_VEND_TIMEOUT_SECONDS=45
```

Set `NAYAX_CALLBACK_AUTH_TOKEN` only if Nayax agrees to send the same token in `x-nayax-auth` or as a bearer token. Existing `STRIPE_SECRET_KEY` and `STRIPE_WEBHOOK_SECRET` must remain configured.

The callback functions use `verify_jwt = false` because Nayax cannot provide a Supabase user JWT. They correlate the Clean Stream transaction, environment, device, amount, currency, and callback event before approving.

## 3. Stripe

Ensure the production webhook endpoint for the existing `stripeWebhook` function receives:

- `checkout.session.completed`
- `payment_intent.succeeded`

The webhook only starts Cortina when Stripe metadata, amount, PaymentIntent, and vend session match. Refund requests use a session-level idempotency key.

## 4. Database and functions

Apply migrations `supabase/migrations/20260803150427_cortina_qr_remote_vend.sql` and `supabase/migrations/20260804015500_cortina_rls_policy_cleanup.sql`, then deploy:

```text
cortina-vend
nayax-sale-end-sandbox
nayax-sale-end
stripeWebhook
```

Deploy the migration before any function. Do not enable a machine until its migrated washer rate and device mapping have been reviewed.

## 5. Washer rates and machine mappings

In the web location administration page:

1. Review each migrated washer size tier or add the intended per-location tiers.
2. Confirm each washer uses the correct tier. Changing a tier updates future quotes and the compatibility `Machines.Price`; existing vend sessions retain their quoted cents.
3. Open the payment setup action for each machine.
4. Enter `TerminalId` or `UniQR`, pulse line, and sandbox environment.
5. Save, run a physical sandbox vend, and enable only after the mapping is verified.
6. Download and print the generated Clean Stream QR label.

Dryers always quote $0.25 per five minutes. Customers select $0.25 through $4.50, with $1.50 as the default.

## 6. Domain links

Follow `CORTINA_DOMAIN_SETUP.md` in the web repository. Apple association data is ready for the current Team ID and bundle ID. Android remains blocked until the production release-certificate SHA-256 fingerprint is placed in `assetlinks.json`.

The host must serve `/pay` as the React application and both `.well-known` files directly with HTTP 200, `application/json`, and no redirects.

## 7. Certification

Certify on Nayax sandbox hardware before production:

- Washer flat-rate card and wallet vends
- Every dryer amount and five-minute conversion
- Decline, Start rejection, callback mismatch, duplicate callbacks, Void, timeout, refund, and wallet reversal
- iOS Universal Link, Android App Link, ordinary camera browser fallback, and in-app scanner handling

Enable production one machine at a time. Verify its QR token, location price, terminal or UniQR, pulse line, refund path, and physical pulse before moving to the next machine.
