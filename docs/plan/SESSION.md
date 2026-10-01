---
date: 2026-10-01
source: chat
origin: ai
type: plan
status: decision
derived_from:
  - projects/flick/ROADMAP.md
  - reviewed Flick product decisions, 2026-10-01
generated_by: AI agent (Forge trunks)
reviewed: false
sensitivity: normal
tags: [flick, session, agents]
---

# Flick — AI session start (one trunk only)

## Shared branch workflow (all agents)

All cloud and local agents work on the shared trunk branch **`main`** (the repository default):
- Work on `main` only; do not create or use feature branches unless Ryan explicitly says to.
- Before starting, pull and rebase onto the latest `main` (for example, `git pull --rebase origin main`).
- Push handoff commits to `main` so the next agent can continue from the same branch.
- Do not create parallel long-lived branches for trunks.

## Before you touch code
1. Read **this** file.
2. Treat this in-repo plan as self-contained; cloud agents do not need vault access.
3. Skim [`ROADMAP.md`](./ROADMAP.md) north star + principles (do not re-plan the whole roadmap).
4. Open **exactly one** trunk under [`trunks/`](./trunks/) — the ID Ryan named, or the first **ready** trunk in the current queue **T11 → T12 → T13 → T14** whose deps are met.
5. Optionally skim locked product notes if the trunk cites them:
   - [`README.md`](./README.md) — wedge + monetization locks
   - [`seed-shelf-2026-10-01.md`](./seed-shelf-2026-10-01.md) — dogfood titles
6. Code lives at the repository root (**`../`** from this file), with Flutter under **`../app/`**. Specs under `../docs/` are useful; T08/T09 monetization is shipped, and no further paywall work precedes the UX queue.

## Product locks + provenance
- **Wedge:** public-domain fiction finishers; Flick is an anti-doomscroll reader with shorts, Listen/karaoke, and Finish moments.
- **Monetization:** freemium Pro at **$4.99/mo** or **$29.99/yr**; premium voices and ad-free are Pro perks; never paywall public-domain books/chapters.
- **Launch ads:** house Pro soft prompts only; rewarded premium-voice trial is optional Phase 1.5; native shorts ads and Finish interstitials wait for Phase 2.
- **Provenance:** this plan is a 2026-10-01 in-repo mirror of Ryan's reviewed Flick planning decisions from the thought-repo. It is intentionally self-contained for cloud agents; do not block on `AGENTS.md` or vault access.

## Max scope (~200k token session)
Assume context = code + docs + tools burns fast.

| Do | Don’t |
|----|--------|
| Implement **only** the open trunk’s in-scope items | Chain into the next trunk “while you’re here” |
| Run that trunk’s acceptance tests | Big-refactor architecture / rename entire Plus→Pro codebase unless trunk says so |
| Touch listed “files likely”; small extras OK if required for green tests | Redesign Bounce, AI TLDR, social, accounts |
| Leave a **handoff note** on the trunk file (or a dated note under `docs/plan/`) | Rely on chat memory for the next agent |
| Keep prompt overhead low: prefer trunk file + 2–3 source files at a time | Dump entire `lib/` into context |

**Hard stop:** if remaining work is another trunk’s job, stop and hand off.

## Session checklist
- [ ] One trunk ID chosen and stated in your working notes
- [ ] Deps satisfied (or blocked — report and stop)
- [ ] Acceptance tests defined before coding
- [ ] Changes limited to in-scope
- [ ] Tests / manual dogfood path run
- [ ] Handoff written; CATALOG/INDEX updated if you added durable notes
- [ ] Keep durable handoff notes in this in-repo plan; no thought-repo or vault access is required

## Current next queue

`T01`–`T14` are complete (including UX/covers). **Do not** start T10 without Ryan unlock. Open [`post-ux-queue.md`](./post-ux-queue.md) and implement **one** theme Ryan chooses (or a new trunk file). T08/T09 paywall is shipped; avoid paywall churn unless asked.

## Ryan dogfood bar (early trunks)
Through **T03**, success means Ryan can: open app → see **Bartleby** on the shelf → Story-swipe → Listen → reach a **Finish** moment in one sitting. Later trunks must not regress that path.
