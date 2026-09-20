/** Minimal MOBI text extraction for common uncompressed / text-heavy files. */
export async function parseMobiFile(
  file: File,
): Promise<{ title: string; text: string }> {
  const buffer = await file.arrayBuffer();
  const bytes = new Uint8Array(buffer);
  const title = file.name.replace(/\.mobi$/i, "");

  const chunks: string[] = [];
  let current = "";

  const pushCurrent = () => {
    const cleaned = current.replace(/[^\x20-\x7E\n]/g, " ").replace(/\s+/g, " ").trim();
    if (cleaned.length > 80) chunks.push(cleaned);
    current = "";
  };

  for (let i = 0; i < bytes.length; i++) {
    const c = bytes[i];
    if (c === 10 || c === 13 || (c >= 32 && c <= 126)) {
      current += String.fromCharCode(c);
      if (current.length > 4000) pushCurrent();
    } else if (current.length > 0) {
      pushCurrent();
    }
  }
  pushCurrent();

  const text = chunks
    .sort((a, b) => b.length - a.length)
    .slice(0, 120)
    .join("\n\n")
    .trim();

  if (!text || text.length < 200) {
    throw new Error(
      "Could not extract enough text from MOBI. Try EPUB or TXT for this title.",
    );
  }

  return { title, text };
}
