# AGENTS.md

Guide for future agents working in the Clean Stream Laundry client app. The goal is to make each pass easier than the last: read the local shape first, keep changes scoped, and leave the project clearer than you found it.

## Project Context

This is the Clean Stream Laundry client-facing Flutter app for mobile and web. Core user flows include account auth, email/reset deep links, home/location selection, machine start/payment, loyalty wallet funding, transaction history, settings, legal pages, and support requests.

Stable reference points:

- App startup is in `lib/main.dart`; `setupDependencies()` wires services before `RootApp` starts `MaterialApp.router`.
- Routing lives in `lib/core/router/app_router.dart` and uses GoRouter. The app starts at `/loading`, then usually sends users to `/homePage` or `/login`.
- Dependency injection uses GetIt in `lib/core/di/di.dart`.
- Feature code lives under `lib/features/<feature>/`, usually split into the page, controller, and `widgets/`.
- Service interfaces and app models live under `lib/logic/`; Supabase, Stripe, Nayax, Kisi, and notification implementations live under `lib/services/`.
- Shared UI shell pieces live in `lib/features/widgets/`; theme code lives in `lib/core/theme/`; small local persistence helpers live in `lib/core/storage/`.

## Common References

Routes that come up often: `/loading`, `/login`, `/signup`, `/homePage`, `/loyalty`, `/loyalty?loadCard=true`, `/startPage`, `/scanner`, `/paymentPage`, `/settings`, `/editProfile`, `/legal/privacy`, `/legal/terms`, `/legal/loyalty-card`, `/password-reset`, `/reset-protected`, `/email-verification`, and `/change-email-verification`.

Deep links currently use the `clean-stream://` scheme for reset-protected, email-verification, change-email, and oauth flows. Check both the router redirect logic and loading controller when changing auth entry behavior.

Branding assets are in `assets/`. App icon and splash configuration are in `pubspec.yaml`, with generated/platform web splash assets also under `web/`. Auth branding may also touch button assets such as `assets/Google.png`.

Environment keys are loaded from `.env` during dependency setup. Treat Supabase and Stripe configuration as runtime config, not hardcoded app state.

The wallet/payment path crosses `PaymentProcessor`, `PaymentService`/Stripe implementations, `WalletService`, transaction services, and Supabase edge/database code. Trace the full path before changing user balances, payments, or transaction refresh behavior.

Supabase is used for Auth, database access, storage, and Edge Functions. Supabase behavior changes over time, so verify current Supabase docs and changelog before implementing MFA/2FA, Realtime replacement, RLS, storage, or auth/session changes.

## Working Style

Be a practical collaborator: warm, direct, and specific. Ground yourself in the repo before making claims, especially around auth, payments, routing, wallet balances, and loading behavior.

Before editing, read the related feature page, controller, service interface, service implementation, and nearby tests. Prefer the established feature/controller/widget pattern over introducing a new structure.

Keep fixes narrow. Avoid drive-by refactors, dependency churn, generated-file churn, or broad rewrites unless the user explicitly asks for them or the existing code makes a narrow fix unsafe.

Use service interfaces from `lib/logic/services/` and existing GetIt registrations when possible. If a new dependency is needed, wire it through DI intentionally and update tests that construct the affected controller or page.

For UI changes, stay consistent with existing `BasePage`, theme, route, and widget patterns. Make loading, error, and empty states explicit when the workflow can fail.

Preserve user work. Check `git status --short` before and after edits, and never revert unrelated changes unless the user asks.

## Verification

For focused changes, start with the nearest tests under `test/features`, `test/services`, `test/logic`, or `test/core`. For shared auth, routing, wallet, payment, or service behavior, broaden to related test folders.

Useful checks:

- `flutter analyze`
- `flutter test`
- Targeted tests such as `flutter test test/features/home` or `flutter test test/services/supabase`

Markdown-only edits do not need automated tests, but still read the rendered text for clarity and stale instructions.

## Project Notes

`APP_FIX_PRIORITIES.md` is the user's return-to priority list. It is not an agent instruction file, not an automatic work queue, and should not be duplicated here. Only use it when the user asks about priorities or points you to that note.
