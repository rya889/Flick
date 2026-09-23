/**
 * POST /api/tldr — Plus-gated AI condensation proxy (also /v1/tldr).
 * Spec: docs/02-backend-spec.md §9
 *
 * Auth: X-Flick-Entitlement: demo (if FLICK_ALLOW_DEMO_PLUS=1)
 *    or X-Flick-App-User + REVENUECAT_SECRET_API_KEY subscriber check
 *
 * Providers (failover): Groq → Gemini → Vercel AI Gateway
 */

const MAX_CHARS = 3500;
const CACHE = new Map();
const CACHE_MAX = 200;

function cors(res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader(
    'Access-Control-Allow-Headers',
    'Content-Type, Authorization, X-Flick-Entitlement, X-Flick-App-User',
  );
}

function json(res, status, body) {
  res.statusCode = status;
  res.setHeader('Content-Type', 'application/json');
  res.end(JSON.stringify(body));
}

function readBody(req) {
  return new Promise((resolve, reject) => {
    const chunks = [];
    req.on('data', (c) => chunks.push(c));
    req.on('end', () => {
      try {
        const raw = Buffer.concat(chunks).toString('utf8');
        resolve(raw ? JSON.parse(raw) : {});
      } catch (e) {
        reject(e);
      }
    });
    req.on('error', reject);
  });
}

function cacheGet(key) {
  const hit = CACHE.get(key);
  if (!hit) return null;
  if (Date.now() - hit.at > 1000 * 60 * 60 * 6) {
    CACHE.delete(key);
    return null;
  }
  return hit.value;
}

function cacheSet(key, value) {
  if (CACHE.size >= CACHE_MAX) {
    const first = CACHE.keys().next().value;
    CACHE.delete(first);
  }
  CACHE.set(key, { at: Date.now(), value });
}

async function verifyPlus(req) {
  const entitlement = (req.headers['x-flick-entitlement'] || '').toString().trim();
  if (entitlement === 'demo' && process.env.FLICK_ALLOW_DEMO_PLUS === '1') {
    return { ok: true, source: 'demo' };
  }

  const secret = process.env.FLICK_PLUS_SHARED_SECRET?.trim();
  if (secret && entitlement === secret) {
    return { ok: true, source: 'shared_secret' };
  }

  const appUser =
    (req.headers['x-flick-app-user'] || '').toString().trim() ||
    (req.headers.authorization || '').toString().replace(/^Bearer\s+/i, '').trim();
  const rcKey = process.env.REVENUECAT_SECRET_API_KEY?.trim();
  if (appUser && rcKey) {
    try {
      const rc = await fetch(
        `https://api.revenuecat.com/v1/subscribers/${encodeURIComponent(appUser)}`,
        {
          headers: {
            Authorization: `Bearer ${rcKey}`,
            'Content-Type': 'application/json',
          },
        },
      );
      if (!rc.ok) {
        return { ok: false, code: 'RC_LOOKUP_FAILED', status: 401 };
      }
      const data = await rc.json();
      const entitlements = data?.subscriber?.entitlements || {};
      const plus =
        entitlements.flick_plus ||
        entitlements.plus ||
        entitlements['Flick Plus'];
      if (plus && (!plus.expires_date || new Date(plus.expires_date) > new Date())) {
        return { ok: true, source: 'revenuecat' };
      }
      return { ok: false, code: 'NO_PLUS', status: 403 };
    } catch {
      return { ok: false, code: 'RC_ERROR', status: 502 };
    }
  }

  return { ok: false, code: 'NO_ENTITLEMENT', status: 401 };
}

function systemPrompt(mode) {
  const common = `You condense literature for Flick TLDR. Preserve plot, names, and voice. No slang, memes, or modern commentary. Output ONLY valid JSON.`;
  if (mode === 'summary') {
    return `${common} Return {"text":"..."} — 1–3 tight summary sentences covering the passage.`;
  }
  if (mode === 'quotes') {
    return `${common} Return {"text":"..."} — up to two key quoted lines from the passage (use curly quotes), separated by blank lines. Prefer dialogue or pivotal statements.`;
  }
  return `${common} Return {"text":"..."} — a Condense pass at ~35–45% length; readable standalone prose.`;
}

async function callChat({ url, apiKey, model, system, user }) {
  const res = await fetch(url, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${apiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model,
      temperature: 0.35,
      response_format: { type: 'json_object' },
      messages: [
        { role: 'system', content: system },
        { role: 'user', content: user },
      ],
    }),
  });
  const raw = await res.text();
  if (!res.ok) {
    const err = new Error(`provider ${res.status}`);
    err.detail = raw.slice(0, 400);
    err.status = res.status;
    throw err;
  }
  const data = JSON.parse(raw);
  const content = data?.choices?.[0]?.message?.content ?? '';
  let parsed;
  try {
    parsed = JSON.parse(content);
  } catch {
    const err = new Error('non-json model output');
    err.detail = content.slice(0, 300);
    throw err;
  }
  const text = (parsed.text || parsed.tldr || '').toString().trim();
  if (!text) {
    throw new Error('empty model text');
  }
  return { text, model };
}

async function callGemini({ apiKey, model, system, user }) {
  const url = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${encodeURIComponent(apiKey)}`;
  const res = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      systemInstruction: { parts: [{ text: system }] },
      contents: [{ role: 'user', parts: [{ text: user }] }],
      generationConfig: {
        temperature: 0.35,
        responseMimeType: 'application/json',
      },
    }),
  });
  const raw = await res.text();
  if (!res.ok) {
    const err = new Error(`gemini ${res.status}`);
    err.detail = raw.slice(0, 400);
    throw err;
  }
  const data = JSON.parse(raw);
  const content = data?.candidates?.[0]?.content?.parts?.[0]?.text ?? '';
  let parsed;
  try {
    parsed = JSON.parse(content);
  } catch {
    const err = new Error('non-json gemini output');
    err.detail = content.slice(0, 300);
    throw err;
  }
  const text = (parsed.text || parsed.tldr || '').toString().trim();
  if (!text) throw new Error('empty gemini text');
  return { text, model: `google/${model}` };
}

async function runProviders(mode, text, contentHash) {
  const system = systemPrompt(mode);
  const user = `mode=${mode}\ncontentHash=${contentHash || ''}\npassage:\n${text}`;
  const errors = [];

  const groqKey = process.env.GROQ_API_KEY?.trim();
  if (groqKey) {
    try {
      return await callChat({
        url: 'https://api.groq.com/openai/v1/chat/completions',
        apiKey: groqKey,
        model: process.env.GROQ_TLDR_MODEL?.trim() || 'llama-3.1-8b-instant',
        system,
        user,
      });
    } catch (e) {
      errors.push(`groq: ${e.message}`);
    }
  }

  const geminiKey =
    process.env.GEMINI_API_KEY?.trim() ||
    process.env.GOOGLE_GENERATIVE_AI_API_KEY?.trim();
  if (geminiKey) {
    try {
      return await callGemini({
        apiKey: geminiKey,
        model: process.env.GEMINI_TLDR_MODEL?.trim() || 'gemini-2.0-flash-lite',
        system,
        user,
      });
    } catch (e) {
      errors.push(`gemini: ${e.message}`);
    }
  }

  const gateway = process.env.AI_GATEWAY_API_KEY?.trim();
  if (gateway) {
    try {
      return await callChat({
        url: 'https://ai-gateway.vercel.sh/v1/chat/completions',
        apiKey: gateway,
        model: process.env.TLDR_MODEL?.trim() || 'openai/gpt-4o-mini',
        system,
        user,
      });
    } catch (e) {
      errors.push(`gateway: ${e.message}`);
    }
  }

  const err = new Error('All AI providers failed or unconfigured');
  err.detail = errors.join('; ') || 'Set GROQ_API_KEY and/or GEMINI_API_KEY';
  err.code = 'NO_PROVIDER';
  throw err;
}

module.exports = async function handler(req, res) {
  cors(res);

  if (req.method === 'OPTIONS') {
    res.statusCode = 204;
    res.end();
    return;
  }

  if (req.method !== 'POST') {
    return json(res, 405, { error: 'Method not allowed' });
  }

  const gate = await verifyPlus(req);
  if (!gate.ok) {
    return json(res, gate.status || 401, {
      error: 'Flick Plus required for AI TLDR',
      code: gate.code || 'NO_ENTITLEMENT',
    });
  }

  let body;
  try {
    body = await readBody(req);
  } catch {
    return json(res, 400, { error: 'Invalid JSON' });
  }

  const mode = ['condense', 'summary', 'quotes'].includes(body.mode)
    ? body.mode
    : 'condense';
  const text = (body.text || '').toString().trim().slice(0, MAX_CHARS);
  const contentHash = (body.contentHash || '').toString().slice(0, 128);

  if (!text) {
    return json(res, 400, { error: 'Missing text', code: 'NO_TEXT' });
  }
  if (text.length > MAX_CHARS) {
    return json(res, 413, { error: 'Passage too large', code: 'TOO_LARGE' });
  }

  const cacheKey = `${mode}:${contentHash || text.slice(0, 64)}`;
  const cached = cacheGet(cacheKey);
  if (cached) {
    return json(res, 200, { ...cached, cached: true, entitlement: gate.source });
  }

  try {
    const result = await runProviders(mode, text, contentHash);
    const payload = {
      text: result.text,
      mode,
      model: result.model,
      source: 'ai',
      entitlement: gate.source,
    };
    cacheSet(cacheKey, payload);
    return json(res, 200, payload);
  } catch (e) {
    return json(res, e.code === 'NO_PROVIDER' ? 503 : 502, {
      error: e.message || 'TLDR failed',
      code: e.code || 'PROVIDER_ERROR',
      detail: e.detail,
    });
  }
};
