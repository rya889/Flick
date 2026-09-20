import { NextRequest, NextResponse } from "next/server";

export const runtime = "nodejs";
export const maxDuration = 60;

type PassageIn = {
  id: string;
  text: string;
  chapterTitle?: string;
};

type TldrOut = {
  id: string;
  tldr: string;
};

const SYSTEM = `You condense literature into a tight TLDR for readers who want the story without filler.

Rules:
- Preserve plot, character names, concrete actions, and dialogue that matters.
- Cut description, repetition, and throat-clearing.
- Keep the author's voice and era — no slang, no memes, no modern commentary.
- Aim for about 35–45% of the original length (shorter is fine if sparse).
- Output ONLY valid JSON: {"items":[{"id":"...","tldr":"..."}]} with one item per input passage, same ids, same order.
- Each tldr must stand alone as readable prose.`;

function resolveAuth(req: NextRequest): {
  apiKey: string;
  baseURL: string;
} | null {
  const headerKey =
    req.headers.get("x-ai-key")?.trim() ||
    req.headers.get("authorization")?.replace(/^Bearer\s+/i, "").trim();

  if (headerKey) {
    // User-supplied key: OpenAI direct if it looks like sk-, else AI Gateway
    if (headerKey.startsWith("sk-") && !headerKey.startsWith("sk-vercel")) {
      return { apiKey: headerKey, baseURL: "https://api.openai.com/v1" };
    }
    return { apiKey: headerKey, baseURL: "https://ai-gateway.vercel.sh/v1" };
  }

  const gateway =
    process.env.AI_GATEWAY_API_KEY?.trim() ||
    process.env.VERCEL_OIDC_TOKEN?.trim();
  if (gateway) {
    return { apiKey: gateway, baseURL: "https://ai-gateway.vercel.sh/v1" };
  }

  const openai = process.env.OPENAI_API_KEY?.trim();
  if (openai) {
    return { apiKey: openai, baseURL: "https://api.openai.com/v1" };
  }

  return null;
}

function pickModel(baseURL: string): string {
  if (baseURL.includes("openai.com")) {
    return process.env.TLDR_MODEL?.trim() || "gpt-4o-mini";
  }
  return process.env.TLDR_MODEL?.trim() || "openai/gpt-4o-mini";
}

export async function GET() {
  const configured = Boolean(
    process.env.AI_GATEWAY_API_KEY ||
      process.env.VERCEL_OIDC_TOKEN ||
      process.env.OPENAI_API_KEY,
  );
  return NextResponse.json({
    configured,
    hint: configured
      ? "Server AI key ready"
      : "Add an OpenAI or Vercel AI Gateway key in Flick settings, or set AI_GATEWAY_API_KEY / OPENAI_API_KEY on the server",
  });
}

export async function POST(req: NextRequest) {
  const auth = resolveAuth(req);
  if (!auth) {
    return NextResponse.json(
      {
        error:
          "No AI key configured. Add one in Flick settings (OpenAI sk-… or AI Gateway key).",
        code: "NO_AI_KEY",
      },
      { status: 401 },
    );
  }

  let body: { passages?: PassageIn[]; title?: string; author?: string };
  try {
    body = await req.json();
  } catch {
    return NextResponse.json({ error: "Invalid JSON" }, { status: 400 });
  }

  const passages = (body.passages ?? [])
    .filter((p) => p?.id && typeof p.text === "string" && p.text.trim())
    .slice(0, 8);

  if (passages.length === 0) {
    return NextResponse.json({ error: "No passages" }, { status: 400 });
  }

  const bookLine = [body.title, body.author].filter(Boolean).join(" — ");
  const userPayload = {
    book: bookLine || undefined,
    passages: passages.map((p) => ({
      id: p.id,
      chapter: p.chapterTitle,
      text: p.text.slice(0, 2500),
    })),
  };

  const model = pickModel(auth.baseURL);

  try {
    const res = await fetch(`${auth.baseURL}/chat/completions`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${auth.apiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model,
        temperature: 0.35,
        response_format: { type: "json_object" },
        messages: [
          { role: "system", content: SYSTEM },
          {
            role: "user",
            content: `Condense these passages:\n${JSON.stringify(userPayload)}`,
          },
        ],
      }),
    });

    if (!res.ok) {
      const errText = await res.text().catch(() => "");
      return NextResponse.json(
        {
          error: `AI provider error (${res.status})`,
          detail: errText.slice(0, 400),
        },
        { status: 502 },
      );
    }

    const data = (await res.json()) as {
      choices?: { message?: { content?: string } }[];
    };
    const raw = data.choices?.[0]?.message?.content ?? "";
    let parsed: { items?: TldrOut[]; tldrs?: TldrOut[] };
    try {
      parsed = JSON.parse(raw);
    } catch {
      return NextResponse.json(
        { error: "Model returned non-JSON", detail: raw.slice(0, 300) },
        { status: 502 },
      );
    }

    const items = parsed.items ?? parsed.tldrs ?? [];
    const byId = new Map(
      items
        .filter((i) => i?.id && typeof i.tldr === "string")
        .map((i) => [i.id, i.tldr.trim()]),
    );

    const tldrs: TldrOut[] = passages.map((p) => ({
      id: p.id,
      tldr: byId.get(p.id) || p.text.slice(0, 280),
    }));

    return NextResponse.json({ tldrs, model, source: "ai" });
  } catch (e) {
    const message = e instanceof Error ? e.message : "TLDR failed";
    return NextResponse.json({ error: message }, { status: 500 });
  }
}
