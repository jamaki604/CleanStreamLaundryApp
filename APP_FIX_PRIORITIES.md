# App Fix Priorities

Return-to checklist for the app issues to tackle next.

## Recommended Order

1. Fix app logo, splash screen assets, and Google auth branding together.
   - Scope: verify the logo files, app icon references, splash logo, web splash assets, platform manifests, and Google sign-in button/logo/text across auth surfaces.
   - Why first: visible, likely isolated, and easiest to verify.
   - Pair with: any branding asset cleanup.

2. Fix login redirect so successful login never lands on a 404.
   - Scope: inspect auth routing, post-login navigation targets, protected route handling, and deep-link/default route behavior.
   - Why next: it blocks basic app entry and affects later auth/security work.
   - Pair with: main home-screen routing checks.

3. Add Supabase 2FA/MFA for account security.
   - Scope: add Supabase Auth MFA/2FA enrollment, challenge, verification, recovery/error handling, and tests for login/signup account flows.
   - Why here: it belongs after the login redirect is stable and before more first-run account flow changes.
   - Pair with: login redirect, signup, and auth session handling.

4. Change loyalty card terms acceptance to happen only once.
   - Scope: show terms during account signup or immediately before first entry to the main home screen, then persist acceptance on the user profile.
   - Why here: depends on reliable login/home routing and should fit into the first-run account flow.
   - Pair with: login redirect, signup, and first-run onboarding flow.

5. Fix home and wallet loading refresh behavior.
   - Scope: reduce repeated refreshes, cache initial data, avoid unnecessary rebuild/fetch loops, and make loading states feel instant after data exists.
   - Why here: important UX issue, but likely needs more code tracing than the visual/routing fixes.
   - Pair with: Supabase data access cleanup.

6. Remove Supabase Realtime usage and replace it with a free approach.
   - Scope: find all realtime subscriptions/channels, replace with explicit refresh, lightweight polling where needed, local cache updates after writes, or backend-triggered updates only where there is already a free service path.
   - Why last: widest impact and should be done with loading performance work so data fetching is not redesigned twice.
   - Pair with: home/wallet loading improvements.

## Fix Together

- Logo + splash screen + Google auth branding: all are branding/platform/auth-surface polish.
- Login 404 + Supabase 2FA/MFA + loyalty terms: all touch the path from authentication into the main app.
- Home/wallet loading + no Supabase Realtime: both touch data freshness, refresh strategy, and perceived speed.

## Priority Summary

1. Branding polish: logo, splash, and Google auth branding.
2. Entry blockers: login redirect and 404.
3. Account security: Supabase 2FA/MFA.
4. First-run compliance: one-time loyalty terms acceptance.
5. UX performance: home and wallet loading.
6. Data architecture: remove Supabase Realtime and replace with a free refresh strategy.
