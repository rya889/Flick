import JSZip from "jszip";
import { parse as parseHtml } from "node-html-parser";

function stripHtml(html: string): string {
  const root = parseHtml(html);
  root.querySelectorAll("script, style").forEach((el) => el.remove());
  const text = root.text
    .replace(/\s+/g, " ")
    .replace(/([.!?])\s+/g, "$1\n\n")
    .trim();
  return text;
}

function resolvePath(base: string, href: string): string {
  if (href.startsWith("/")) return href.slice(1);
  const parts = base.split("/");
  parts.pop();
  const segments = href.split("/");
  for (const seg of segments) {
    if (seg === "..") parts.pop();
    else if (seg && seg !== ".") parts.push(seg);
  }
  return parts.join("/");
}

export async function parseEpubFile(
  file: File,
): Promise<{ title: string; author?: string; text: string }> {
  const buffer = await file.arrayBuffer();
  const zip = await JSZip.loadAsync(buffer);

  const containerXml = await zip.file("META-INF/container.xml")?.async("string");
  if (!containerXml) throw new Error("Invalid EPUB: missing container.xml");

  const rootfileMatch = containerXml.match(/full-path="([^"]+)"/i);
  if (!rootfileMatch) throw new Error("Invalid EPUB: no rootfile");

  const opfPath = rootfileMatch[1];
  const opfXml = await zip.file(opfPath)?.async("string");
  if (!opfXml) throw new Error("Invalid EPUB: missing OPF");

  const titleMatch = opfXml.match(/<dc:title[^>]*>([^<]+)<\/dc:title>/i);
  const authorMatch = opfXml.match(/<dc:creator[^>]*>([^<]+)<\/dc:creator>/i);
  const title = titleMatch?.[1]?.trim() || file.name.replace(/\.epub$/i, "");
  const author = authorMatch?.[1]?.trim();

  const manifest: Record<string, string> = {};
  const manifestRe = /<item\s+[^>]*id="([^"]+)"[^>]*href="([^"]+)"[^>]*media-type="([^"]+)"[^>]*\/?>/gi;
  let m: RegExpExecArray | null;
  while ((m = manifestRe.exec(opfXml))) {
    manifest[m[1]] = m[2];
  }

  const spineIds: string[] = [];
  const spineRe = /<itemref\s+[^>]*idref="([^"]+)"[^>]*\/?>/gi;
  while ((m = spineRe.exec(opfXml))) {
    spineIds.push(m[1]);
  }

  const opfDir = opfPath.includes("/") ? opfPath.replace(/\/[^/]+$/, "") : "";
  const textParts: string[] = [];

  for (const id of spineIds) {
    const href = manifest[id];
    if (!href) continue;
    const fullPath = opfDir ? `${opfDir}/${href}` : href;
    const resolved = resolvePath(opfPath, href);
    const entry = zip.file(resolved) ?? zip.file(fullPath);
    if (!entry) continue;
    const html = await entry.async("string");
    const plain = stripHtml(html);
    if (plain) textParts.push(plain);
  }

  const text = textParts.join("\n\n").trim();
  if (!text) throw new Error("Could not extract text from EPUB");

  return { title, author, text };
}
