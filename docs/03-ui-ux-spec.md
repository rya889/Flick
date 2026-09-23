# Flick — UI/UX Spec v0

**Status:** Closed (definitive for redesign)  
**Depends on:** [01-product-design-spec.md](./01-product-design-spec.md), [02-backend-spec.md](./02-backend-spec.md)

**Pitch on store / paywalls:** *The anti-doomscroll reader.*

---

## 1. Design principles

- One composition per screen; player is not a dashboard  
- Brand **Flick** is a hero-level signal on empty/marketing surfaces; on Now, karaoke content leads  
- TikTok/IG energy; reading clarity first  
- Preserve what already worked in v0 web: **karaoke autoplay + chapter/progress up top**  
- Controls **always visible** (no cinema auto-hide)  
- System/auto theme with user override  

## 2. Information architecture

### Bottom tabs (3)

| Tab | Behavior |
|-----|----------|
| **Now** | Player shell; Story by default; resumes last short |
| **Library** | Full-screen catalog + import |
| **Bounce** | Activates Bounce on the **Now** player (do not ship a second duplicate player). If &lt;3 books → soft prompt |

### Header on Now

**Story | Bounce** pill (stays in sync with Bounce tab).

## 3. Now / Player

### Keep from v0

- Top **chapter progress pips**  
- Chapter **‹ Ch / Ch ›** controls  

### Gestures (locked)

| Gesture | Action |
|---------|--------|
| Vertical swipe | Next / previous short |
| Side tap (left/right) | Previous / next short |
| Double-tap | Heart |

### Listen (IG-style)

- Session audio on after first user unlock / start; **mute** always available  
- **Speed** control always in chrome  
- Free: at 60 min/day TTS stops → paywall; text + karaoke continue  

### TLDR controls

- **Full | TLDR** toggle  
- If TLDR: segmented control **Condense · Summary · Quotes**  
- AI generating: **inline skeleton** on that short; **do not block swipe** (show Full or extractive until AI ready)  

### Motion (required)

1. Short → short transition  
2. Karaoke word highlight  
3. Heart burst  

### Share / save

- **Share:** system sheet with quote text (image optional later)  
- **Save:** bookmarks / reading list — **separate** from hearts  

## 4. Bounce UX

- Soft prompt when library &lt; 3 books (point to samples + import)  
- TLDR-preferred presentation; Full allowed via same toggles  
- Same player chrome as Story so learning transfers  

## 5. Library

- **Full-screen** tab (not a modal)  
- Empty state: large **Add book** + samples entry  
- Import v1: EPUB, TXT, paste  
- Rows: cover hue, title, progress, resume affordance  
- Prefer simple list rows over heavy card grids  

## 6. Paywalls (all three)

1. Listen daily cap hit  
2. First AI TLDR action  
3. Settings → manage / subscribe  

Show: pitch line, $6.99/mo, $49.99/yr, 7-day trial on yearly, what Plus unlocks (AI TLDR + unlimited Listen).

## 7. Visual system

### Theme

Default **System**; Settings: **System / Light / Dark**.

### Color — Signal Coral

Short-form energy (hearts, progress, CTA) + calm reading surfaces. Avoid purple-SaaS gradients and cream+terracotta clichés.

| Token | Light | Dark |
|-------|-------|------|
| `--bg` | `#F7F4F1` | `#0E0F12` |
| `--surface` | `#FFFFFF` | `#1A1C22` |
| `--ink` | `#14151A` | `#F2F0EC` |
| `--ink-muted` | `#5C5F6A` | `#9A9DA8` |
| `--signal` | `#FF3B2E` | `#FF5A4F` |
| `--signal-soft` | `#FF3B2E22` | `#FF5A4F33` |
| `--success` | `#1F8A5B` | `#3DDC97` |
| Progress / pips | `--signal` | `--signal` |
| Errors | `#B00020` | `#FF8A80` |

Hearts use `--signal`. Primary CTAs use `--signal` on contrasting ink/surface.

### Typography

- **Display** (wordmark / empty states): expressive (e.g. Fraunces or Syne)  
- **Body / karaoke:** readable serif or humane reading face (e.g. Source Serif or Literata)  
- Avoid defaulting to Inter / Roboto / Arial-only stacks  

## 8. Screen inventory

1. Now / Story player  
2. Now / Bounce player (same shell)  
3. Bounce soft-prompt (&lt;3 books)  
4. Library list  
5. Library empty + Add book  
6. Import (file / paste)  
7. TLDR segmented + AI skeleton state  
8. Listen-cap paywall  
9. AI TLDR paywall  
10. Settings (theme, Plus, default speed)  
11. Bookmarks (saves)  
12. System share handoff  

## 9. Accessibility (baseline)

- Dynamic type where feasible without breaking karaoke layout  
- Mute must not remove ability to read  
- Contrast AA for body text on `--bg` / `--surface`  
- Reduce-motion: keep karaoke usable; soften heart burst / transitions  

## 10. Resolved IA decision

**Bounce tab** deep-links into **Now + Bounce mode** (single player). Documented as locked default from design recommendation.
