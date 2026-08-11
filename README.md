# Bars From Behind v1.0 — Static Prototype

Open `index.html` directly or deploy the folder to any static host. No build step is required.

## Temporary manager demo
Email: manager.demo@barsfrombehind.test
Password: BFB-DEMO-2026!
Expires: September 8, 2026

The demo login is front-end-only and is not production authentication. Replace it with server-side auth, expiring invitations, scoped permissions/RLS, and audit logs before launch.

## Launch cities
Los Angeles, Houston, Dallas-Fort Worth, Phoenix, Chicago, Miami, Atlanta, New York City, Memphis, New Orleans. Facility/provider compatibility must be verified before activating local recording numbers.


## v1.1 additions
- Supabase browser configuration placeholder (`config.js`)
- Supabase Auth client foundation in `app.js`
- Artist/Representative, Temporary Manager, and Admin portal cards
- Launch-city/facility schema
- Expiring manager assignments with scoped permissions
- Audit-log table
- Seed data for the 10 initial BFB launch markets
- Row Level Security starter policies

### Required environment values
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

Never expose `SUPABASE_SERVICE_ROLE_KEY` in the website/browser.

### Temporary manager security
Production temporary managers are invitation-only. Their database assignment has `starts_at`, `expires_at`, `revoked_at`, and scoped `permissions`. The manager role must not be allowed to redirect payouts, transfer ownership/copyright, alter identity records, or grant itself additional access.
