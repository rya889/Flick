# Flick — cloud-agent start guide

Cloud agents do not have thought-repo or vault access. The complete session entry point is in this repository.

## Shared branch workflow (all agents)

All cloud and local agents work on the shared trunk branch **`main`** (the repository default):
- Work on `main` only; do not create or use feature branches unless Ryan explicitly says to.
- Before starting, pull and rebase onto the latest `main` (for example, `git pull --rebase origin main`).
- Push handoff commits to `main` so the next agent can continue from the same branch.
- Do not create parallel long-lived branches for trunks.

1. Start at the repository root and read [`docs/plan/SESSION.md`](./SESSION.md).
2. Read [`docs/plan/ROADMAP.md`](./ROADMAP.md) only far enough to understand the north star and ordering.
3. Choose **exactly one** file under [`docs/plan/trunks/`](./trunks/): the trunk Ryan named, or the first `ready` trunk in the current queue **T11 → T12 → T13 → T14** whose dependencies are met.
4. Read that trunk's scope, acceptance tests, and handoff. Do not open the next trunk “while you’re here.”
5. Implement only the chosen trunk. Code is at the repository root, with Flutter code under [`app/`](../../app/).
6. Run the trunk's acceptance checks, record results, and leave a concise handoff on the trunk before stopping.

If a trunk is blocked or the remaining work belongs to another trunk, stop and report it rather than re-planning the roadmap.

## Current next queue

**T18 (TestFlight prep) is ready; T17 (ship-stabilize) is complete.** Read [`trunks/T18-testflight-prep.md`](./trunks/T18-testflight-prep.md), then follow [`release-milestones.md`](./release-milestones.md) for the nine-gate iOS-first path. This is signing/IPA/metadata preparation only—no new features. T10 ads, Bounce, cloud TTS, and accounts/sync for 1.0 remain parked.
