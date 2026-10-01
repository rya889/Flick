---
date: 2026-10-01
source: chat
origin: ai
type: project
status: decision
derived_from: [Ryan's explicit product decision, 2026-10-01]
generated_by: AI agent
reviewed: true
reviewed_on: 2026-10-01
sensitivity: normal
tags: [public-domain, fiction, finishers]
---

# Flick

Ebook reading as short-form / social + auto-read.

## Current intent — locked 2026-10-01 (ET)
- Primary segment: **public-domain fiction finishers**.
- Value prop: tap a large free/public-domain fiction corpus — a library of free books — to help finish fiction.
- Primary user flavor: **TikTok/Instagram-native anti-doomscroll** — wants more than brain rot; Finish + shorts + Listen/karaoke.
- Commute Listen / audio-first is an inherent capability (reader → sound/play on text) and the third priority, not the wedge to design around.

## Monetization — locked 2026-10-01 (ET)
**Ladder:** freemium + Pro **$4.99/mo** / **$29.99/yr** (annual emphasized on paywall). Optional later lifetime ~$49.99 for non-metered UX only.

| Lock | Detail |
| --- | --- |
| **Premium voices** | **Inside Pro** (simple ladder — no Voice add-on) |
| **Ad-free** | **Pro perk** |
| **Free ads** | See the v1 launch default below and the ads brief |
| **Launch ads default (v1)** | House Pro soft prompts only; optional opt-in rewarded premium-voice trial (Phase 1.5); native shorts ads and Finish interstitial deferred to Phase 2 after retention/momentum. |
| **Never paywall** | Public-domain books / chapters |

Full competitor table + free/Pro matrix: [pricing-research-2026-10-01.md](./pricing-research-2026-10-01.md)  
Ads strategy + persona re-validate: [ads-and-audience-pricing-2026-10-01.md](./ads-and-audience-pricing-2026-10-01.md)

## Execution — incremental trunks (2026-10-01)
**Method:** one bite-size trunk per ~200k-token AI session. Do not try to ship the whole product in one go.

| Doc | Role |
| --- | --- |
| [ROADMAP.md](./ROADMAP.md) | North star, principles, ordered trunk list |
| [SESSION.md](./SESSION.md) | How an AI starts a session (one trunk only) |
| [trunks/](./trunks/) | One short file per trunk (scope + acceptance + handoff) |

**Next trunk to run:** `T01-foundation-baseline` (then T02 seed shelf → T03 Bartleby dogfood).

**Seed shelf:** [seed-shelf-2026-10-01.md](./seed-shelf-2026-10-01.md)  
**Code:** repository root (`../` from this plan; Flutter under `../app/`)

## Parked
- Nonfiction skimmers / TLDR for now: AI-generated CLDR/TLDR quality may suffer and would need curation. Spend time on the fiction wedge instead.

## Links
- Code: repository root (`../`)
- Plan: [ROADMAP.md](./ROADMAP.md) · [SESSION.md](./SESSION.md) · [trunks/](./trunks/)
- Repo: (add URL)

## Open questions
- Broader PD library source? → trunks T06–T07
- Content rights path?
- Lifetime SKU timing (later only for non-metered)?
- Student plan post-PMF?
