# Flick — Deploy & secrets

## Durable web (Vercel)

Repo root deploys Flutter web + `/v1/*` AI proxy:

| Path | Role |
|------|------|
| `scripts/vercel-install.sh` | Clone Flutter stable, `pub get` |
| `scripts/vercel-build.sh` | `flutter build web --release` |
| `api/health.js` | `GET /v1/health` |
| `api/tldr.js` | `POST /v1/tldr` (Plus-gated) |
| `vercel.json` | SPA + API rewrites |

Project (LeTeam): connect GitHub `rya889/Flick`, production branch as desired (this PR uses `cursor/design-docs-and-archive-983e` until merge).

### Server env (Vercel → Project → Settings → Environment Variables)

| Key | Required | Purpose |
|-----|----------|---------|
| `GROQ_API_KEY` | Recommended | Primary free TLDR provider |
| `GEMINI_API_KEY` | Optional | Failover |
| `AI_GATEWAY_API_KEY` | Optional | Vercel AI Gateway failover |
| `FLICK_ALLOW_DEMO_PLUS` | Set `1` for web demos | Accepts `X-Flick-Entitlement: demo` |
| `REVENUECAT_SECRET_API_KEY` | For real Plus checks | Verifies subscriber via RC REST |
| `FLICK_PLUS_SHARED_SECRET` | Optional | Alternate entitlement header value |

Without any AI provider key, `/v1/tldr` returns `503 NO_PROVIDER`.

### Client dart-defines (native builds)

```bash
flutter run \
  --dart-define=REVENUECAT_API_KEY=appl_xxx \
  --dart-define=FLICK_API_BASE=https://YOUR_PROJECT.vercel.app
```

Web on the same Vercel host can leave `FLICK_API_BASE` empty (same-origin `/v1`).

## RevenueCat checklist (user)

1. Create RevenueCat project + apps (iOS / Android).  
2. Entitlement id: `flick_plus`.  
3. Products: `flick_plus_monthly` ($6.99), `flick_plus_yearly` ($49.99, 7-day trial).  
4. Offering `default` with monthly + annual packages.  
5. Paste **public** SDK keys into CI/`--dart-define=REVENUECAT_API_KEY`.  
6. Paste **secret** API key into Vercel `REVENUECAT_SECRET_API_KEY`.  
7. App Store Connect + Play Console paid-apps enrollment (paid yearly accounts).  

Until those exist, paywall uses **demo Plus** on web / when no SDK key is compiled in.
