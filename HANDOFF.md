# Flick — Cloud Agent Handoff

**Agent:** https://cursor.com/agents/bc-01a0b1f0-1672-72e1-a604-41512c9eb735  
**GitHub (empty until pushed):** https://github.com/rya889/Flick  
**Vercel project:** https://vercel.com/le-team2/flick-shorts  

## Where the code lived on the agent VM

- App root: `/agent/flick` (Next.js 16 App Router)
- Branch prepared for push: `main` @ `4d03617`
- No GitHub credentials on this agent (started without a repo)

## Artifacts in this folder

| File | What |
|------|------|
| `flick-source.zip` | Source tree (no `node_modules` / `.next`) |
| `flick.bundle` | Full git history — clone with `git clone flick.bundle Flick` |
| `HANDOFF.md` | This file |
| `CONTEXT.md` | Product + technical context |

## Restore locally / in another Cursor session

```bash
# Option A — from zip
unzip flick-source.zip -d Flick && cd Flick && npm install

# Option B — from git bundle (keeps commits)
git clone flick.bundle Flick && cd Flick && npm install

# Then push to GitHub (on a machine with auth)
git remote add origin https://github.com/rya889/Flick.git
git checkout -B main
git push -u origin main
```

## After GitHub has code

1. In Vercel → `flick-shorts` → Settings → Git → connect `rya889/Flick`
2. Or start a **new** Cloud Agent from `https://github.com/rya889/Flick`
