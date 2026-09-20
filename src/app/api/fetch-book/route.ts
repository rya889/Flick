import { NextRequest, NextResponse } from "next/server";

export const runtime = "nodejs";

function extractTitle(html: string): string | undefined {
  const m = html.match(/<title[^>]*>([^<]+)<\/title>/i);
  return m?.[1]?.trim();
}

function htmlToText(html: string): string {
  return html
    .replace(/<script[\s\S]*?<\/script>/gi, "")
    .replace(/<style[\s\S]*?<\/style>/gi, "")
    .replace(/<br\s*\/?>/gi, "\n")
    .replace(/<\/p>/gi, "\n\n")
    .replace(/<[^>]+>/g, " ")
    .replace(/\s+/g, " ")
    .replace(/([.!?])\s+/g, "$1\n\n")
    .trim();
}

export async function GET(req: NextRequest) {
  const url = req.nextUrl.searchParams.get("url");
  if (!url) {
    return NextResponse.json({ error: "Missing url parameter" }, { status: 400 });
  }

  let parsed: URL;
  try {
    parsed = new URL(url);
  } catch {
    return NextResponse.json({ error: "Invalid URL" }, { status: 400 });
  }

  if (!["http:", "https:"].includes(parsed.protocol)) {
    return NextResponse.json({ error: "Only HTTP(S) URLs supported" }, { status: 400 });
  }

  try {
    const res = await fetch(url, {
      headers: { "User-Agent": "Flick/1.0 (book importer)" },
      redirect: "follow",
    });
    if (!res.ok) {
      return NextResponse.json({ error: `Fetch failed (${res.status})` }, { status: 502 });
    }
    const contentType = res.headers.get("content-type") ?? "";
    const body = await res.text();

    if (contentType.includes("text/html")) {
      const text = htmlToText(body);
      if (text.length < 100) {
        return NextResponse.json({ error: "Page had too little readable text" }, { status: 422 });
      }
      return NextResponse.json({ title: extractTitle(body), text });
    }

    if (
      contentType.includes("text/plain") ||
      url.endsWith(".txt") ||
      !contentType.includes("application/")
    ) {
      const text = body.trim();
      if (text.length < 50) {
        return NextResponse.json({ error: "Text too short" }, { status: 422 });
      }
      return NextResponse.json({ text });
    }

    return NextResponse.json(
      { error: "Unsupported content type. Link to HTML or plain text." },
      { status: 415 },
    );
  } catch (e) {
    const message = e instanceof Error ? e.message : "Fetch error";
    return NextResponse.json({ error: message }, { status: 500 });
  }
}
