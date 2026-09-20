export async function parseTxtFile(file: File): Promise<string> {
  return file.text();
}

export function parseTxtString(text: string): string {
  return text.replace(/\r\n/g, "\n").trim();
}
