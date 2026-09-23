/**
 * Lightweight entitlement/gate checks for the TLDR proxy (no network providers).
 * Run: node api/tldr.test.js
 */
const assert = require('assert');
const http = require('http');

process.env.FLICK_ALLOW_DEMO_PLUS = '1';
delete process.env.GROQ_API_KEY;
delete process.env.GEMINI_API_KEY;
delete process.env.AI_GATEWAY_API_KEY;

const health = require('./health.js');
const tldr = require('./tldr.js');

function mockRes() {
  return {
    statusCode: 0,
    headers: {},
    body: '',
    setHeader(k, v) {
      this.headers[k] = v;
    },
    end(b) {
      this.body = b || '';
    },
  };
}

function mockReq({ method = 'GET', headers = {}, body } = {}) {
  const req = new http.IncomingMessage();
  req.method = method;
  req.headers = headers;
  if (body !== undefined) {
    process.nextTick(() => {
      req.emit('data', Buffer.from(JSON.stringify(body)));
      req.emit('end');
    });
  } else if (method === 'POST') {
    process.nextTick(() => req.emit('end'));
  }
  return req;
}

async function run() {
  const hRes = mockRes();
  health(mockReq({ method: 'GET' }), hRes);
  const healthBody = JSON.parse(hRes.body);
  assert.strictEqual(healthBody.ok, true);
  assert.strictEqual(healthBody.plusGate.demoPlus, true);

  const denied = mockRes();
  await tldr(
    mockReq({
      method: 'POST',
      headers: {},
      body: { mode: 'condense', text: 'Hello world passage for gate test.' },
    }),
    denied,
  );
  assert.strictEqual(denied.statusCode, 401);

  const noProvider = mockRes();
  await tldr(
    mockReq({
      method: 'POST',
      headers: { 'x-flick-entitlement': 'demo' },
      body: { mode: 'condense', text: 'Hello world passage for provider test.' },
    }),
    noProvider,
  );
  assert.strictEqual(noProvider.statusCode, 503);
  const np = JSON.parse(noProvider.body);
  assert.strictEqual(np.code, 'NO_PROVIDER');

  console.log('api/tldr.test.js OK');
}

run().catch((e) => {
  console.error(e);
  process.exit(1);
});
