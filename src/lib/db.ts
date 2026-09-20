import type {
  CatalogBook,
  ParsedBook,
  ReadingProgress,
  ShortSegment,
  UploadJob,
} from "./types";

const DB_NAME = "flick-catalog-v1";
const DB_VERSION = 1;

type StoreName = "books" | "shorts" | "progress" | "uploads";

function openDb(): Promise<IDBDatabase> {
  return new Promise((resolve, reject) => {
    const req = indexedDB.open(DB_NAME, DB_VERSION);
    req.onerror = () => reject(req.error);
    req.onsuccess = () => resolve(req.result);
    req.onupgradeneeded = () => {
      const db = req.result;
      if (!db.objectStoreNames.contains("books")) {
        db.createObjectStore("books", { keyPath: "id" });
      }
      if (!db.objectStoreNames.contains("shorts")) {
        const s = db.createObjectStore("shorts", { keyPath: "id" });
        s.createIndex("bookId", "bookId", { unique: false });
      }
      if (!db.objectStoreNames.contains("progress")) {
        db.createObjectStore("progress", { keyPath: "bookId" });
      }
      if (!db.objectStoreNames.contains("uploads")) {
        db.createObjectStore("uploads", { keyPath: "id" });
      }
    };
  });
}

async function tx<T>(
  store: StoreName,
  mode: IDBTransactionMode,
  fn: (os: IDBObjectStore) => IDBRequest<T> | void,
): Promise<T | void> {
  const db = await openDb();
  return new Promise((resolve, reject) => {
    const transaction = db.transaction(store, mode);
    const os = transaction.objectStore(store);
    const result = fn(os);
    transaction.oncomplete = () => {
      if (result instanceof IDBRequest) {
        resolve(result.result as T);
      } else {
        resolve();
      }
    };
    transaction.onerror = () => reject(transaction.error);
  });
}

export async function saveBookWithShorts(
  book: ParsedBook,
  shorts: ShortSegment[],
  shortCount: number,
): Promise<CatalogBook> {
  const catalog: CatalogBook = { ...book, shortCount };
  await tx("books", "readwrite", (os) => os.put(catalog));
  for (const short of shorts) {
    await tx("shorts", "readwrite", (os) => os.put(short));
  }
  return catalog;
}

export async function getAllBooks(): Promise<CatalogBook[]> {
  const db = await openDb();
  return new Promise((resolve, reject) => {
    const req = db.transaction("books", "readonly").objectStore("books").getAll();
    req.onsuccess = () => {
      const books = (req.result as CatalogBook[]).sort((a, b) => b.addedAt - a.addedAt);
      resolve(books);
    };
    req.onerror = () => reject(req.error);
  });
}

export async function getBook(id: string): Promise<CatalogBook | undefined> {
  return (await tx("books", "readonly", (os) => os.get(id))) as CatalogBook | undefined;
}

export async function deleteBook(id: string): Promise<void> {
  await tx("books", "readwrite", (os) => os.delete(id));
  const db = await openDb();
  await new Promise<void>((resolve, reject) => {
    const t = db.transaction("shorts", "readwrite");
    const idx = t.objectStore("shorts").index("bookId");
    const range = IDBKeyRange.only(id);
    const cursorReq = idx.openCursor(range);
    cursorReq.onsuccess = () => {
      const cursor = cursorReq.result;
      if (cursor) {
        cursor.delete();
        cursor.continue();
      }
    };
    t.oncomplete = () => resolve();
    t.onerror = () => reject(t.error);
  });
  await tx("progress", "readwrite", (os) => os.delete(id));
}

export async function getShortsForBook(bookId: string): Promise<ShortSegment[]> {
  const db = await openDb();
  return new Promise((resolve, reject) => {
    const idx = db.transaction("shorts", "readonly").objectStore("shorts").index("bookId");
    const req = idx.getAll(bookId);
    req.onsuccess = () => {
      const list = (req.result as ShortSegment[]).sort((a, b) => a.index - b.index);
      resolve(list);
    };
    req.onerror = () => reject(req.error);
  });
}

export async function saveProgress(progress: ReadingProgress): Promise<void> {
  await tx("progress", "readwrite", (os) => os.put(progress));
}

export async function getProgress(bookId: string): Promise<ReadingProgress | undefined> {
  return (await tx("progress", "readonly", (os) => os.get(bookId))) as
    | ReadingProgress
    | undefined;
}

export async function getAllProgress(): Promise<ReadingProgress[]> {
  const db = await openDb();
  return new Promise((resolve, reject) => {
    const req = db.transaction("progress", "readonly").objectStore("progress").getAll();
    req.onsuccess = () => resolve(req.result as ReadingProgress[]);
    req.onerror = () => reject(req.error);
  });
}

export async function saveUploadJob(job: UploadJob): Promise<void> {
  await tx("uploads", "readwrite", (os) => os.put(job));
}

export async function getUploadJobs(): Promise<UploadJob[]> {
  const db = await openDb();
  return new Promise((resolve, reject) => {
    const req = db.transaction("uploads", "readonly").objectStore("uploads").getAll();
    req.onsuccess = () => {
      const jobs = (req.result as UploadJob[]).sort((a, b) => b.id.localeCompare(a.id));
      resolve(jobs);
    };
    req.onerror = () => reject(req.error);
  });
}

export async function clearFinishedUploads(): Promise<void> {
  const jobs = await getUploadJobs();
  for (const job of jobs.filter((j) => j.status === "done")) {
    await tx("uploads", "readwrite", (os) => os.delete(job.id));
  }
}
