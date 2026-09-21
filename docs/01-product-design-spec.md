# Flick — Product Design Spec v1.1

**Status:** Closed (definitive for redesign)  
**Name:** Flick (working)  
**Pitch:** *The anti-doomscroll reader.*

Alt pitches (not primary):  
- *Finish books in shorts—karaoke text, listen, swipe—built for brains trained on TikTok.*  
- *Swipe your book. Listen along. Actually finish it.*

---

## 1. Thesis

Flick is more than an e-reader. It uses the same low-effort dopamine mechanisms as TikTok/Instagram (shorts, autoplay, swipe, hearts, listen + karaoke text) so short-attention users **finish books instead of doomscrolling**.

At its core it remains a **book / document reading** app.

## 2. Jobs & metrics

| Priority | Job |
|----------|-----|
| Primary | Finish books via snackable units |
| Secondary | Displace doomscrolling; snack reading |
| Support | Listen while looking at karaoke text (background lock-screen audio **not** required for v1) |

**North-star metric:** shorts finished  

**Supporting:** book completion %, sessions/week, listen minutes  

**Cold open:** land on **last book / last short** (TikTok-like resume).

## 3. Audience & platforms

- Everyone, but primarily **short-attention** readers who like TikTok / Instagram / Reddit  
- Day-to-day: **iPhone and Android**  
- Social later: hearts on sections, comments, follow libraries, public feeds, share snippets out  
- **v1 social:** local hearts only; comments / follow / public feeds **post-v1**

## 4. Modes

### Story (default home)

- Stay in **one book**, chapter-aware, narrative continuity  
- **Full text default**; TLDR optional  
- When TLDR **Condense** is on: stay in **chapter order** on condensed shorts (never skip ahead)  
- Summary / Key quotes may appear as chapter-boundary or alternate tracks; spine stays sequential  

### Bounce (free on day one; addictive)

- Opt-in secondary mode  
- Requires **≥3 books** in library (public-domain samples **count**)  
- **TLDR-preferred**, Full allowed  
- Algorithmic context change across library (and within-book variety)  
- Soft prompt to import/samples when &lt;3 books — do not hard-error  
- May move behind Plus later; **v1 ships Bounce free**

### TLDR submodes (all three)

| Submode | Meaning | Best fit |
|---------|---------|----------|
| **Condense** | Same beat, fewer words; still “reading through” | Story + Bounce |
| **Summary** | Chapter/section gist | Story boundaries, Bounce |
| **Key quotes** | Highlight lines | Bounce, share |

AI TLDR is Plus. Free users get **extractive lite-TLDR** only (instant, lower quality).

**Do not scrape Goodreads** (or similar) for summaries — ToS / legal / App Store risk. Prefer: user book text + AI, public-domain packs, Open Library metadata later.

## 5. Content model — what is a short?

- Prefer **paragraph** when it fits  
- If too long: split on sentence boundaries to a **snack reading time**  
- Engagement sweet spot (TikTok/IG analogy): **~15–60 seconds** of attention  
- Default target: **~20–45 sec** ≈ **~60–120 words** @ ~180 wpm  
- Soft max ~60–75 sec; don’t chase platform *maximum* video lengths  

## 6. Audio

- **Listen is core** for engagement  
- **v1 default:** OS on-device TTS (free, offline)  
- Mute + playback speed; karaoke can run with audio muted  
- **No** background / lock-screen listening requirement in v1  
- **Cloud TTS voices = Plus (later)**  

**Free Listen cap:** **60 minutes / day** (TTS only; reading continues).  
**Plus:** unlimited Listen.

## 7. AI roles

| Job | v1 |
|-----|-----|
| TLDR (Condense / Summary / Quotes) | Plus, online, cacheable |
| Chapter summaries | Via Summary submode / Plus |
| Recommend next short | Bounce algorithm (rules first; AI later) |
| Generate visuals for shorts | Plus roadmap, not day-one live |

**Principle:** Core experience works **without** AI. Instant extractive fallback on device; paid/cloud AI for advanced quality.

## 8. Library & import

**v1 must-have imports:** EPUB, TXT, paste  

**Later:** PDF, MOBI, URL, bookstore sync  

**Content:** user files required; ship **3 public-domain samples** so Bounce can unlock  

**For You feed:** demoted (not primary)  

**Progress:** resume exact short; chapter jump; bookmarks  

## 9. Engagement — keep / kill

| Keep | Kill / demote |
|------|----------------|
| Hearts, saves (bookmarks), share, playback speed | Streaks, daily goals |
| Karaoke autoplay, chapter/progress chrome | For You as home |

**Heart:** personal bookmark signal + future social + light Bounce training  

**Share v1:** system share sheet with quote text (optional image later)  

**Save:** separate from hearts (reading list / bookmarks)

## 10. Privacy & accounts

- **Local-first** for prototype / v1  
- **No login in v1** (IAP only)  
- Accounts + sync when sync/social land  
- Book text **never leaves device** except when a Plus user requests AI on **that short only**  
- Cloud storage of full books: deferred  

## 11. Monetization

| Item | Decision |
|------|----------|
| Model | Subscription (**Flick Plus**) |
| Price | **$6.99/mo** and **$49.99/yr** |
| Trial | **7-day free trial** on yearly |
| Restore / Family Sharing | Not required for v1 |

### Free

- Story mode (Full), karaoke, chapter nav  
- Bounce (free, addictive)  
- OS Listen up to **60 min/day**  
- Hearts, saves, share, speed  
- Extractive lite-TLDR  
- EPUB / TXT / paste + samples  

### Plus (day one live)

- **AI TLDR** (Condense / Summary / Quotes)  
- **Unlimited Listen**  

### Plus-reserved (paywall copy OK; build next)

- Cloud TTS voices  
- Sync (needs accounts)  
- AI visuals  

No ads in the reading surface (would contradict anti-doomscroll thesis).

## 12. Constraints

- Budget: **as free as possible** (solo project)  
- App Store + Play for v1; **prioritize paid/freemium** so revenue can start early  
- Brand feel: TikTok / Instagram energy applied to books  

## 13. Explicit non-goals for v1

- Full social graph (comments, follow, public feeds)  
- PDF / MOBI / bookstore sync  
- Background audio  
- Analytics  
- Accounts / cloud book vault  
- Goodreads (or similar) scraping  

## 14. Platform decision

**Flutter / Dart** for iOS + Android native — chosen to fix structural web failures (gestures, TTS, offline). Web is not the v1 product surface.

## 15. Success criteria for v1 ship

- User can import a book, resume last short, karaoke through Story, Listen with OS TTS  
- Bounce works with samples + ≥3 books and feels addictive  
- Free caps and Plus paywalls work (Listen + AI)  
- Offline Story + Listen (within cap) without network
