/**
 * GET /api/health — public uptime (also /v1/health via rewrite).
 */
module.exports = function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.setHeader(
    'Access-Control-Allow-Headers',
    'Content-Type, Authorization, X-Flick-Entitlement, X-Flick-App-User',
  );

  if (req.method === 'OPTIONS') {
    res.statusCode = 204;
    res.end();
    return;
  }

  if (req.method !== 'GET') {
    res.statusCode = 405;
    res.setHeader('Content-Type', 'application/json');
    res.end(JSON.stringify({ error: 'Method not allowed' }));
    return;
  }

  const groq = Boolean(process.env.GROQ_API_KEY?.trim());
  const gemini = Boolean(
    process.env.GEMINI_API_KEY?.trim() || process.env.GOOGLE_GENERATIVE_AI_API_KEY?.trim(),
  );
  const gateway = Boolean(process.env.AI_GATEWAY_API_KEY?.trim());
  const demoPlus = process.env.FLICK_ALLOW_DEMO_PLUS === '1';
  const rcSecret = Boolean(process.env.REVENUECAT_SECRET_API_KEY?.trim());

  res.statusCode = 200;
  res.setHeader('Content-Type', 'application/json');
  res.end(
    JSON.stringify({
      ok: true,
      service: 'flick-tldr',
      providers: { groq, gemini, gateway },
      plusGate: { demoPlus, revenueCat: rcSecret },
    }),
  );
};
